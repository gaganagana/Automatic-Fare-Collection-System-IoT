/*
 * =====================================================================================
 * PROJECT    : SMART BUS SYSTEM - COMPLETE NODEMCU ESP8266 FIRMWARE (UTF-8 & CLEAN UI)
 * PLATFORM   : NODEMCU ESP8266 / ESP-12E (9600 BAUD BI-DIRECTIONAL ARDUINO LINK)
 * =====================================================================================
 * EXACT HARDWARE CONNECTIONS:
 *  1. Arduino Link RX : Pin D2 (RX) <-- Connected to Arduino Pin A2 (TX) via 1k/2k Divider
 *  2. Arduino Link TX : Pin D7 (TX) <-- Connected to Arduino Pin A3 (RX) [MANDATORY FOR RECHARGE & BLOCK]
 *  3. Green LED       : Pin D5 (GPIO 14) -> 220R -> LED (+) -> GND
 *  4. Red LED         : Pin D6 (GPIO 12) -> 220R -> LED (+) -> GND
 *  5. Common Ground   : NodeMCU GND  <-- Connected to Breadboard GND (- Rail) (CRITICAL!)
 * =====================================================================================
 */

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <SoftwareSerial.h>

// --- WI-FI CREDENTIALS ---
const char* WIFI_SSID     = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// --- PIN DEFINITIONS (EXACT HARDWARE PINS) ---
#define PIN_UNO_RX      D2   // Receives triggers from Arduino Pin A2 (via voltage divider)
#define PIN_UNO_TX      D7   // Sends commands (Register/Recharge/Block) to Arduino Pin A3
#define PIN_GREEN_LED   D5   // Green LED (Valid Entry / Exit / Activated)
#define PIN_RED_LED     D6   // Red LED (Access Denied / Low Balance / Blocked / Inactivated)

SoftwareSerial unoSerial(PIN_UNO_RX, PIN_UNO_TX); // RX on D2, TX on D7
ESP8266WebServer server(80);
WiFiClient wifiClient;

// --- DYNAMIC PHONE IP DISCOVERY ---
String phoneIp = ""; // Automatically captured when phone opens NodeMCU web page
const int PHONE_PORT = 8080;

// --- ROUTE STOPS ---
const char* stopCodes[] = {
  "S00", "S01", "S02", "S03", "S04", "S05", "S06", "S07", "S08", "S09",
  "S10", "S11", "S12", "S13", "S14", "S15", "S16", "S17", "S18"
};

const char* stopNames[] = {
  "None",
  "Kempegowda Bus Station",
  "Maharani College",
  "K. R. Circle",
  "St. Martha's Hospital",
  "Corporation",
  "Poornima Talkies",
  "Lalbagh Main Gate",
  "Lalbagh West Gate",
  "Ashoka Pillar",
  "Rani Sarala School",
  "Jayanagar 3rd Block",
  "Jayanagar 4th Block",
  "Jayanagar Church",
  "Sanjay Gandhi Hospital",
  "Carmel Convent",
  "Pump House",
  "East End Jayanagar",
  "16th Main BTM Layout"
};

// --- MULTI-CARD LOCAL DATABASE (EXPANDABLE UP TO 15 CARDS) ---
struct CardData {
  String uid;
  String name;
  int balance;
  bool isBlocked;
};

#define MAX_CARDS 15
int cardCount = 7;

CardData localCards[MAX_CARDS] = {
  {"5402BBA9", "Bhanu",     200, false},
  {"63E6D51D", "Karthik",   5,   false},   // Inactive/Blocked by default
  {"F0C27F5F", "Gayathri",  200, false},
  {"90444455", "Nharika",   200, false},
  {"5B850B1A", "Kanthesh",  200, false},
  {"3D085006", "Shyamala",  5,   false},  // Low Balance (< Rs.10)
  {"21DB3E0A", "Prema",     50,  true}    // Inactive/Blocked by default
};

// --- LIVE STATE ---
int currentStop = 1;
bool isMoving = false;
String lastEvent = "SYSTEM READY";
String lastEventCode = "INIT";
String lastUid = "5402BBA9";
String lastName = "Bhanu";
int lastBalance = 200;
int lastFare = 0;
String entryStopName = "Kempegowda Bus Station";
unsigned long eventSeq = 0;

// --- SEND COMMAND TO ARDUINO ---
void sendCommandToArduino(const String& cmd) {
  noInterrupts();
  unoSerial.println(cmd);
  unoSerial.flush();
  interrupts();
  
  delay(30);
  
  noInterrupts();
  unoSerial.println(cmd);
  unoSerial.flush();
  interrupts();

  Serial.printf("[COMMAND SENT TO ARDUINO (PIN D7)]: %s\n", cmd.c_str());
}

// --- LED CONTROLS ---
void triggerGreen() {
  Serial.println(F(">>> [NODEMCU LED]: GREEN ON (Valid Card / Activated - 2.5s)"));
  digitalWrite(PIN_RED_LED, LOW);
  digitalWrite(PIN_GREEN_LED, HIGH);
  delay(2500);
  digitalWrite(PIN_GREEN_LED, LOW);
}

void triggerRed() {
  Serial.println(F(">>> [NODEMCU LED]: RED ON / FLASHING (Denied / Blocked / Inactivated)"));
  digitalWrite(PIN_GREEN_LED, LOW);
  for (int i = 0; i < 3; i++) {
    digitalWrite(PIN_RED_LED, HIGH);
    delay(300);
    digitalWrite(PIN_RED_LED, LOW);
    delay(200);
  }
}

// --- SEND HTTP POST TO FLUTTER APP ---
void postHttp(const String& endpoint, const String& jsonBody) {
  if (WiFi.status() != WL_CONNECTED) {
    return;
  }
  if (phoneIp.length() == 0) {
    return;
  }

  HTTPClient http;
  String url = "http://" + phoneIp + ":" + String(PHONE_PORT) + endpoint;
  http.begin(wifiClient, url);
  http.setTimeout(400);
  http.addHeader("Content-Type", "application/json");

  int httpCode = http.POST(jsonBody);
  if (httpCode > 0) {
    Serial.printf("[HTTP -> %s]: Delivered (Code %d)\n", url.c_str(), httpCode);
  }
  http.end();
}

// --- PUSH CARD EVENT TO FLUTTER APP ---
void pushCardEvent(const String& type, const String& uid, const String& name, const String& stop, int fare, int balance, const String& entryStop, const String& exitStop, int stopsTravelled) {
  String jsonEvent = "{";
  jsonEvent += "\"uid\":\"" + uid + "\",";
  jsonEvent += "\"name\":\"" + name + "\",";
  jsonEvent += "\"type\":\"" + type + "\",";
  jsonEvent += "\"event\":\"" + type + "\",";
  jsonEvent += "\"stop\":\"" + stop + "\",";
  jsonEvent += "\"fare\":" + String(fare) + ",";
  jsonEvent += "\"balance\":" + String(balance) + ",";
  jsonEvent += "\"entryStop\":\"" + entryStop + "\",";
  jsonEvent += "\"exitStop\":\"" + exitStop + "\",";
  jsonEvent += "\"stopsTravelled\":" + String(stopsTravelled);
  jsonEvent += "}";

  postHttp("/api/bus/event", jsonEvent);
  postHttp("/", jsonEvent);
}

// --- PUSH BUS STOP MOVEMENT TO FLUTTER APP ---
void pushBusStop(int stopNum, const String& stopName, bool moving) {
  String jsonStop = "{";
  jsonStop += "\"stopNum\":" + String(stopNum) + ",";
  jsonStop += "\"stopName\":\"" + stopName + "\",";
  jsonStop += "\"moving\":" + String(moving ? "true" : "false");
  jsonStop += "}";

  postHttp("/api/bus/stop", jsonStop);

  String jsonLegacy = "{";
  if (moving) {
    jsonLegacy += "\"event\":\"BUS_DEPARTED\",\"fromStop\":\"" + stopName + "\"";
  } else {
    const char* sCode = (stopNum >= 1 && stopNum <= 18) ? stopCodes[stopNum] : "S01";
    jsonLegacy += "\"event\":\"STOP_ARRIVED\",\"stopCode\":\"" + String(sCode) + "\",\"stopName\":\"" + stopName + "\"";
  }
  jsonLegacy += "}";
  postHttp("/", jsonLegacy);
}

// --- JSON API FOR FLUTTER POLLING & STATUS ---
void handleApiStatus() {
  phoneIp = server.client().remoteIP().toString();

  const char* sCode = (currentStop >= 1 && currentStop <= 18) ? stopCodes[currentStop] : "S01";
  const char* sName = (currentStop >= 1 && currentStop <= 18) ? stopNames[currentStop] : "Kempegowda Bus Station";

  String json = "{";
  json += "\"status\":\"online\",";
  json += "\"eventSeq\":" + String(eventSeq) + ",";
  json += "\"event\":\"" + lastEventCode + "\",";
  json += "\"type\":\"" + lastEventCode + "\",";
  json += "\"stopCode\":\"" + String(sCode) + "\",";
  json += "\"stopName\":\"" + String(sName) + "\",";
  json += "\"stop\":" + String(currentStop) + ",";
  json += "\"moving\":" + String(isMoving ? "true" : "false") + ",";
  json += "\"name\":\"" + lastName + "\",";
  json += "\"uid\":\"" + lastUid + "\",";
  json += "\"balance\":" + String(lastBalance) + ",";
  json += "\"fare\":" + String(lastFare) + ",";
  json += "\"entryStop\":\"" + entryStopName + "\",";
  json += "\"lastEvent\":\"" + lastEvent + "\",";
  json += "\"ip\":\"" + WiFi.localIP().toString() + "\"";
  json += "}";

  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", json);
}

// --- HANDLE DYNAMIC CARD REGISTRATION ---
void handleRegisterCard() {
  phoneIp = server.client().remoteIP().toString();

  String uid = "";
  String name = "New User";
  int balance = 200;

  if (server.hasArg("uid")) uid = server.arg("uid");
  if (server.hasArg("name")) name = server.arg("name");
  if (server.hasArg("balance")) balance = server.arg("balance").toInt();

  // If posted as raw JSON
  if (server.hasArg("plain")) {
    String body = server.arg("plain");
    int uIdx = body.indexOf("\"uid\"");
    if (uIdx != -1) {
      int c = body.indexOf(':', uIdx);
      int q1 = body.indexOf('"', c);
      int q2 = body.indexOf('"', q1 + 1);
      if (q1 != -1 && q2 != -1) uid = body.substring(q1 + 1, q2);
    }
    int nIdx = body.indexOf("\"name\"");
    if (nIdx != -1) {
      int c = body.indexOf(':', nIdx);
      int q1 = body.indexOf('"', c);
      int q2 = body.indexOf('"', q1 + 1);
      if (q1 != -1 && q2 != -1) name = body.substring(q1 + 1, q2);
    }
    int bIdx = body.indexOf("\"balance\"");
    if (bIdx != -1) {
      int c = body.indexOf(':', bIdx);
      int comma = body.indexOf(',', c);
      int brace = body.indexOf('}', c);
      int endPos = (comma != -1 && comma < brace) ? comma : brace;
      if (c != -1 && endPos != -1) balance = body.substring(c + 1, endPos).toInt();
    }
  }

  uid.toUpperCase();
  uid.replace(" ", "");

  if (uid.length() == 0) {
    server.send(400, "application/json", "{\"status\":\"error\",\"message\":\"Missing UID\"}");
    return;
  }

  bool exists = false;
  for (int i = 0; i < cardCount; i++) {
    if (localCards[i].uid.equalsIgnoreCase(uid)) {
      localCards[i].name = name;
      localCards[i].balance = balance;
      localCards[i].isBlocked = false;
      exists = true;
      break;
    }
  }

  if (!exists && cardCount < MAX_CARDS) {
    localCards[cardCount].uid = uid;
    localCards[cardCount].name = name;
    localCards[cardCount].balance = balance;
    localCards[cardCount].isBlocked = false;
    cardCount++;
  }

  // Send registration command to Arduino: REGISTER,UID,NAME,BALANCE\n
  sendCommandToArduino("REGISTER," + uid + "," + name + "," + String(balance));

  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", "{\"status\":\"ok\",\"message\":\"Card registered successfully\",\"uid\":\"" + uid + "\",\"name\":\"" + name + "\",\"balance\":" + String(balance) + "}");
  
  triggerGreen();
}

// --- HANDLE RECHARGE ---
void handleRecharge() {
  phoneIp = server.client().remoteIP().toString();

  String uid = "";
  int amount = 100;
  String name = "";
  int exactBalance = -1;

  if (server.hasArg("uid")) uid = server.arg("uid");
  if (server.hasArg("amount")) amount = server.arg("amount").toInt();
  if (server.hasArg("balance")) exactBalance = server.arg("balance").toInt();
  if (server.hasArg("name")) name = server.arg("name");

  // Check JSON body
  if (server.hasArg("plain")) {
    String body = server.arg("plain");
    int uIdx = body.indexOf("\"uid\"");
    if (uIdx != -1) {
      int c = body.indexOf(':', uIdx);
      int q1 = body.indexOf('"', c);
      int q2 = body.indexOf('"', q1 + 1);
      if (q1 != -1 && q2 != -1) uid = body.substring(q1 + 1, q2);
    }
    int bIdx = body.indexOf("\"balance\"");
    if (bIdx != -1) {
      int c = body.indexOf(':', bIdx);
      int comma = body.indexOf(',', c);
      int brace = body.indexOf('}', c);
      int endPos = (comma != -1 && comma < brace) ? comma : brace;
      if (c != -1 && endPos != -1) exactBalance = body.substring(c + 1, endPos).toInt();
    }
    int aIdx = body.indexOf("\"amount\"");
    if (aIdx != -1) {
      int c = body.indexOf(':', aIdx);
      int comma = body.indexOf(',', c);
      int brace = body.indexOf('}', c);
      int endPos = (comma != -1 && comma < brace) ? comma : brace;
      if (c != -1 && endPos != -1) amount = body.substring(c + 1, endPos).toInt();
    }
  }

  uid.toUpperCase();
  uid.replace(" ", "");

  if (uid.length() == 0) {
    server.send(400, "application/json", "{\"status\":\"error\",\"message\":\"Missing UID\"}");
    return;
  }

  int addAmount = (exactBalance != -1) ? (exactBalance - 5) : amount;
  if (addAmount <= 0) addAmount = 100;

  bool found = false;
  for (int i = 0; i < cardCount; i++) {
    if (localCards[i].uid.equalsIgnoreCase(uid)) {
      if (exactBalance != -1) {
        localCards[i].balance = exactBalance;
      } else {
        localCards[i].balance += amount;
      }
      if (name.length() > 0) localCards[i].name = name;
      lastUid = uid;
      lastName = localCards[i].name;
      lastBalance = localCards[i].balance;
      found = true;
      break;
    }
  }

  if (!found && cardCount < MAX_CARDS) {
    String uName = (name.length() > 0) ? name : "New User";
    localCards[cardCount].uid = uid;
    localCards[cardCount].name = uName;
    localCards[cardCount].balance = (exactBalance != -1) ? exactBalance : amount;
    localCards[cardCount].isBlocked = false;
    lastUid = uid;
    lastName = uName;
    lastBalance = localCards[cardCount].balance;
    cardCount++;

    sendCommandToArduino("REGISTER," + uid + "," + uName + "," + String(localCards[cardCount - 1].balance));
  } else {
    // Send command to Arduino: RECHARGE,UID,AMOUNT\n
    sendCommandToArduino("RECHARGE," + uid + "," + String(addAmount));
  }

  // Push updated balance to Flutter App
  const char* sName = (currentStop >= 1 && currentStop <= 18) ? stopNames[currentStop] : "Kempegowda Bus Station";
  pushCardEvent("RECHARGE", uid, lastName, String(sName), 0, lastBalance, "", "", 0);

  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", "{\"status\":\"ok\",\"balance\":" + String(lastBalance) + "}");
  
  triggerGreen();
}

// --- HANDLE CARD ACTIVATE / DEACTIVATE (INACTIVATE) ---
void handleCardStatus() {
  phoneIp = server.client().remoteIP().toString();

  String uid = "";
  String statusStr = "";
  int statusVal = -1; // -1 = unknown, 1 = Active, 0 = Inactive / Blocked

  if (server.hasArg("uid")) uid = server.arg("uid");
  if (server.hasArg("status")) statusStr = server.arg("status");
  if (server.hasArg("action")) statusStr = server.arg("action");
  if (server.hasArg("isBlocked")) {
    String b = server.arg("isBlocked");
    b.toLowerCase();
    if (b == "true" || b == "1") statusVal = 0; // blocked
    else statusVal = 1; // active
  }

  // Parse JSON body if present
  if (server.hasArg("plain")) {
    String body = server.arg("plain");
    int uIdx = body.indexOf("\"uid\"");
    if (uIdx != -1) {
      int c = body.indexOf(':', uIdx);
      int q1 = body.indexOf('"', c);
      int q2 = body.indexOf('"', q1 + 1);
      if (q1 != -1 && q2 != -1) uid = body.substring(q1 + 1, q2);
    }
    int sIdx = body.indexOf("\"status\"");
    if (sIdx != -1) {
      int c = body.indexOf(':', sIdx);
      int comma = body.indexOf(',', c);
      int brace = body.indexOf('}', c);
      int endPos = (comma != -1 && comma < brace) ? comma : brace;
      if (c != -1 && endPos != -1) {
        statusStr = body.substring(c + 1, endPos);
        statusStr.replace("\"", "");
        statusStr.trim();
      }
    }
    int bIdx = body.indexOf("\"isBlocked\"");
    if (bIdx != -1) {
      int c = body.indexOf(':', bIdx);
      int comma = body.indexOf(',', c);
      int brace = body.indexOf('}', c);
      int endPos = (comma != -1 && comma < brace) ? comma : brace;
      if (c != -1 && endPos != -1) {
        String bStr = body.substring(c + 1, endPos);
        bStr.trim();
        bStr.toLowerCase();
        if (bStr == "true" || bStr == "1") statusVal = 0;
        else statusVal = 1;
      }
    }
  }

  uid.toUpperCase();
  uid.replace(" ", "");

  if (uid.length() == 0) {
    server.send(400, "application/json", "{\"status\":\"error\",\"message\":\"Missing UID\"}");
    return;
  }

  if (statusVal == -1) {
    statusStr.trim();
    statusStr.toUpperCase();
    if (statusStr == "0" || statusStr == "BLOCKED" || statusStr == "DEACTIVATE" || statusStr == "INACTIVATE" || statusStr == "FALSE" || statusStr == "LOCK") {
      statusVal = 0;
    } else {
      statusVal = 1;
    }
  }

  bool isBlocked = (statusVal == 0);

  // Update local NodeMCU database
  for (int i = 0; i < cardCount; i++) {
    if (localCards[i].uid.equalsIgnoreCase(uid)) {
      localCards[i].isBlocked = isBlocked;
      break;
    }
  }

  // 1. Send Command to Arduino Pin A3
  sendCommandToArduino("CARDSTATUS," + uid + "," + String(statusVal));

  // 2. Send HTTP Response immediately
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", "{\"status\":\"ok\",\"uid\":\"" + uid + "\",\"isBlocked\":" + String(isBlocked ? "true" : "false") + "}");

  // 3. Trigger LED on NodeMCU:
  // Green LED if Activated (statusVal == 1)
  // Red LED if Inactivated / Blocked (statusVal == 0)
  if (statusVal == 1) {
    Serial.println(F(">>> [NODEMCU LED]: GREEN ON (Card Activated)"));
    digitalWrite(PIN_RED_LED, LOW);
    digitalWrite(PIN_GREEN_LED, HIGH);
    delay(2000);
    digitalWrite(PIN_GREEN_LED, LOW);
  } else {
    Serial.println(F(">>> [NODEMCU LED]: RED ON (Card Inactivated / Blocked)"));
    digitalWrite(PIN_GREEN_LED, LOW);
    digitalWrite(PIN_RED_LED, HIGH);
    delay(2000);
    digitalWrite(PIN_RED_LED, LOW);
  }
}

// --- WEB DASHBOARD & PHONE AUTO-LINK ---
void handleRoot() {
  phoneIp = server.client().remoteIP().toString();

  const char* sCode = (currentStop >= 1 && currentStop <= 18) ? stopCodes[currentStop] : "S01";
  const char* sName = (currentStop >= 1 && currentStop <= 18) ? stopNames[currentStop] : "Kempegowda Bus Station";

  String html = "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width,initial-scale=1'>"
  "<title>Smart Bus IoT Control Hub</title>"
  "<style>"
  "body{font-family:Arial,sans-serif;background:#0f172a;color:#f8fafc;margin:0;padding:12px;text-align:center;}"
  ".card{background:#1e293b;border-radius:14px;padding:14px;max-width:440px;margin:auto;box-shadow:0 4px 14px rgba(0,0,0,0.4);}"
  ".badge{display:inline-block;padding:5px 12px;border-radius:20px;font-size:12px;font-weight:bold;margin-bottom:8px;}"
  ".badge-moving{background:#0284c7;color:#fff;}"
  ".badge-stopped{background:#16a34a;color:#fff;}"
  ".stat-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin:12px 0;}"
  ".stat-box{background:#334155;padding:8px;border-radius:8px;text-align:left;}"
  ".stat-label{font-size:11px;color:#94a3b8;}"
  ".stat-val{font-size:14px;font-weight:bold;color:#f8fafc;margin-top:2px;}"
  ".btn{display:inline-block;padding:8px 10px;border-radius:6px;font-weight:bold;text-decoration:none;font-size:11px;cursor:pointer;border:none;margin:3px;}"
  ".btn-green{background:#16a34a;color:#fff;}"
  ".btn-red{background:#dc2626;color:#fff;}"
  ".btn-blue{background:#2563eb;color:#fff;}"
  ".card-table{width:100%;border-collapse:collapse;margin-top:12px;font-size:12px;text-align:left;}"
  ".card-table th{background:#334155;padding:6px;color:#94a3b8;}"
  ".card-table td{padding:6px;border-bottom:1px solid #334155;}"
  ".reg-box{background:#1e293b;border:1px solid #3b82f6;border-radius:10px;padding:10px;margin-top:14px;text-align:left;}"
  "input{width:92%;padding:6px;margin:4px 0 8px;border-radius:4px;border:1px solid #475569;background:#0f172a;color:#fff;font-size:12px;}"
  "</style>"
  "<script>"
  "function doAction(url, msg){"
  "  fetch(url).then(r=>r.json()).then(d=>{"
  "    alert(msg + ' (Done!)');"
  "    location.reload();"
  "  }).catch(e=>alert('Action triggered!'));"
  "}"
  "</script></head><body>"
  "<div class='card'>"
  "<h1 style='color:#38bdf8;margin:0 0 6px 0;font-size:18px;'>[BUS] SMART BUS FLEET HUB</h1>"
  "<div style='font-size:11px;color:#4ade80;margin-bottom:10px;'>[PHONE] PAIRED PHONE: ";
  html += phoneIp;
  html += " (Port 8080)</div>"
  "<div id='status' class='badge ";
  html += (isMoving ? "badge-moving'>BUS IN TRANSIT >>" : "badge-stopped'>BUS AT STOP");
  html += "</div><h2 id='stop' style='color:#e2e8f0;margin:6px 0;font-size:15px;'>";
  html += String(sCode) + ": " + String(sName);
  html += "</h2>"
  "<div class='stat-grid'>"
  "<div class='stat-box'><div class='stat-label'>Last Activity</div><div class='stat-val' style='color:#38bdf8;'>";
  html += lastEvent;
  html += "</div></div><div class='stat-box'><div class='stat-label'>Passenger</div><div class='stat-val'>";
  html += lastName + " (" + lastUid + ")";
  html += "</div></div><div class='stat-box'><div class='stat-label'>Fare Deducted</div><div class='stat-val' style='color:#fbbf24;'>Rs. ";
  html += String(lastFare);
  html += "</div></div><div class='stat-box'><div class='stat-label'>Remaining Balance</div><div class='stat-val' style='color:#4ade80;'>Rs. ";
  html += String(lastBalance);
  html += "</div></div></div>"

  // PASSENGER MANAGEMENT TABLE
  "<div style='font-size:13px;font-weight:bold;color:#38bdf8;margin-top:12px;text-align:left;'>PASSENGER SMART CARDS:</div>"
  "<table class='card-table'>"
  "<tr><th>Name</th><th>Bal</th><th>Status</th><th>Actions</th></tr>";

  for (int i = 0; i < cardCount; i++) {
    html += "<tr>";
    html += "<td><b>" + localCards[i].name + "</b><br><span style='color:#94a3b8;font-size:10px;'>" + localCards[i].uid + "</span></td>";
    html += "<td>Rs." + String(localCards[i].balance) + "</td>";
    if (localCards[i].isBlocked) {
      html += "<td style='color:#f87171;font-weight:bold;'>BLOCKED</td>";
      html += "<td><button class='btn btn-green' onclick=\"doAction('/card-status?uid=" + localCards[i].uid + "&status=1', 'Activated " + localCards[i].name + "');\">Activate</button>";
    } else {
      html += "<td style='color:#4ade80;font-weight:bold;'>ACTIVE</td>";
      html += "<td><button class='btn btn-red' onclick=\"doAction('/card-status?uid=" + localCards[i].uid + "&status=0', 'Inactivated " + localCards[i].name + "');\">Inactivate</button>";
    }
    html += "<button class='btn btn-blue' onclick=\"doAction('/recharge?uid=" + localCards[i].uid + "&amount=100', 'Recharged " + localCards[i].name + " +Rs.100');\">+Rs.100</button></td>";
    html += "</tr>";
  }

  html += "</table>"

  // DYNAMIC REGISTRATION FORM
  "<div class='reg-box'>"
  "<div style='font-size:12px;font-weight:bold;color:#38bdf8;'>REGISTER NEW SMART CARD</div>"
  "<form action='/register' method='GET'>"
  "<div style='font-size:10px;color:#94a3b8;'>Card UID (Hex):</div>"
  "<input type='text' name='uid' placeholder='e.g. A1B2C3D4' required>"
  "<div style='font-size:10px;color:#94a3b8;'>Holder Name:</div>"
  "<input type='text' name='name' placeholder='e.g. Project Guide / Ravi' required>"
  "<div style='font-size:10px;color:#94a3b8;'>Initial Balance (Rs):</div>"
  "<input type='number' name='balance' value='200' required>"
  "<button class='btn btn-green' type='submit' style='width:100%;font-size:12px;padding:8px;'>REGISTER & ALLOW CARD ON BUS</button>"
  "</form></div>"

  "<div style='font-size:10px;color:#64748b;margin-top:10px;'>NodeMCU IP: ";
  html += WiFi.localIP().toString();
  html += "</div></div></body></html>";

  server.send(200, "text/html", html);
}

void setup() {
  Serial.begin(9600);
  unoSerial.begin(9600);

  pinMode(PIN_GREEN_LED, OUTPUT);
  pinMode(PIN_RED_LED, OUTPUT);
  digitalWrite(PIN_GREEN_LED, LOW);
  digitalWrite(PIN_RED_LED, LOW);

  Serial.println(F("\n========================================================"));
  Serial.println(F(" NODEMCU SMART BUS IoT & FLUTTER BRIDGE (9600 BAUD)     "));
  Serial.println(F("========================================================"));
  
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(400);
    Serial.print(F("."));
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println(F("\n========================================================"));
    Serial.println(F("[Wi-Fi] Connected to Airtel_Khan successfully!"));
    Serial.print(F("[Wi-Fi] NodeMCU IP Address: "));
    Serial.println(WiFi.localIP());
    Serial.println(F("Open http://") + WiFi.localIP().toString() + F("/ on your phone once to link!"));
    Serial.println(F("========================================================\n"));
  } else {
    Serial.println(F("\n[Wi-Fi] Offline. Operating in standalone receiver mode."));
  }

  // Endpoints for Flutter app, Browser, and Polling
  server.on("/", HTTP_GET, handleRoot);
  server.on("/status", HTTP_GET, handleApiStatus);
  server.on("/api/status", HTTP_GET, handleApiStatus);
  server.on("/ping", HTTP_GET, handleApiStatus);
  server.on("/register", HTTP_ANY, handleRegisterCard);
  server.on("/recharge", HTTP_ANY, handleRecharge);
  server.on("/card-status", HTTP_ANY, handleCardStatus);

  server.begin();
  Serial.println(F("[HTTP SERVER] Ready on port 80. Waiting for Arduino triggers...\n"));
}

void loop() {
  server.handleClient();

  // Read Telemetry from Arduino UNO Pin A2
  if (unoSerial.available() > 0) {
    String msg = unoSerial.readStringUntil('\n');
    msg.trim();

    if (msg.length() > 0) {
      Serial.print(F("\n[FROM ARDUINO]: "));
      Serial.println(msg);

      // Packet format: EVENT,STOP,BALANCE,UID,NAME,FARE
      int p1 = msg.indexOf(',');
      int p2 = msg.indexOf(',', p1 + 1);
      int p3 = msg.indexOf(',', p2 + 1);
      int p4 = msg.indexOf(',', p3 + 1);
      int p5 = msg.indexOf(',', p4 + 1);

      if (p1 != -1) {
        String eventType = msg.substring(0, p1);
        int stopNum      = (p2 != -1) ? msg.substring(p1 + 1, p2).toInt() : 1;
        int balance      = (p2 != -1 && p3 != -1) ? msg.substring(p2 + 1, p3).toInt() : 0;
        String uid       = (p3 != -1 && p4 != -1) ? msg.substring(p3 + 1, p4) : "";
        String name      = (p4 != -1 && p5 != -1) ? msg.substring(p4 + 1, p5) : (p4 != -1 ? msg.substring(p4 + 1) : "");
        int fare         = (p5 != -1) ? msg.substring(p5 + 1).toInt() : 0;

        currentStop = stopNum;
        if (uid.length() > 0) lastUid = uid;
        if (name.length() > 0) lastName = name;
        lastBalance = balance;
        lastFare = fare;
        eventSeq++;

        const char* sCode = (stopNum >= 1 && stopNum <= 18) ? stopCodes[stopNum] : "S01";
        const char* sName = (stopNum >= 1 && stopNum <= 18) ? stopNames[stopNum] : "Kempegowda Bus Station";

        // 1. VALID ENTRY
        if (eventType == "ENTRY") {
          lastEvent = "ENTRY SUCCESSFUL";
          lastEventCode = "ENTRY";
          isMoving = false;
          entryStopName = String(sName);

          pushCardEvent("ENTRY", lastUid, lastName, String(sName), 0, lastBalance, entryStopName, "", 0);
          triggerGreen();
        }
        // 2. VALID EXIT
        else if (eventType == "EXIT") {
          lastEvent = "EXIT SUCCESSFUL";
          lastEventCode = "EXIT";
          isMoving = false;

          int stopsTravelled = 1;
          pushCardEvent("EXIT", lastUid, lastName, String(sName), lastFare, lastBalance, entryStopName, String(sName), stopsTravelled);
          triggerGreen();
        }
        // 3. LOW BALANCE
        else if (eventType == "LOWBAL") {
          lastEvent = "LOW BALANCE";
          lastEventCode = "DENIED_BALANCE";

          pushCardEvent("DENIED_BALANCE", lastUid, lastName, String(sName), 0, lastBalance, "", "", 0);
          triggerRed();
        }
        // 4. CARD INACTIVE / BLOCKED
        else if (eventType == "DEACTIVATED" || eventType == "BLOCKED") {
          lastEvent = "CARD BLOCKED";
          lastEventCode = "DENIED_INVALID";

          pushCardEvent("DENIED_INVALID", lastUid, lastName, String(sName), 0, lastBalance, "", "", 0);
          triggerRed();
        }
        // 5. INVALID / UNREGISTERED CARD
        else if (eventType == "INVALID") {
          lastEvent = "INVALID CARD";
          lastEventCode = "DENIED_INVALID";

          pushCardEvent("DENIED_INVALID", lastUid, "Unknown", String(sName), 0, 0, "", "", 0);
          triggerRed();
        }
        // 6. BUS START (DEPARTED)
        else if (eventType == "START") {
          isMoving = true;
          lastEvent = "BUS IN TRANSIT";
          lastEventCode = "BUS_DEPARTED";

          pushBusStop(stopNum, String(sName), true);
        }
        // 7. BUS STOP (ARRIVED)
        else if (eventType == "STOP") {
          isMoving = false;
          lastEvent = "BUS AT STOP";
          lastEventCode = "STOP_ARRIVED";

          pushBusStop(stopNum, String(sName), false);
        }
      }
    }
  }
}
