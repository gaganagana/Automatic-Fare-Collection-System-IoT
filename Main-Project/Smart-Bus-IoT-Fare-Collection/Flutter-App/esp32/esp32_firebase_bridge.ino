// ============================================================
//  Smart Bus — ESP32 WiFi / Firebase Bridge
//  Board   : ESP32 Dev Module (separate board from the Arduino UNO)
//
//  JOB OF THIS BOARD (and nothing else):
//   - Receive one-line event reports from the UNO over UART
//   - Forward each one to TWO places:
//       1. The Flutter app's existing embedded server, using the
//          /api/bus/event and /api/bus/stop routes that are ALREADY
//          built into the app (no Android changes needed for this part)
//       2. Firebase Realtime Database, so the same events are visible
//          from anywhere with internet, not just on the same WiFi as
//          the phone
//   - This board makes NO fare decisions. It doesn't know card
//     balances, doesn't run any bus logic — it's a dumb, fast relay.
//     If WiFi is down, or Firebase is unreachable, the UNO keeps
//     working exactly as it always has; this board just has nothing
//     to send until the connection comes back.
//
//  LIBRARIES NEEDED (Arduino IDE -> Library Manager):
//   - "Firebase ESP Client" by Mobizt   (search: firebase esp client)
//   - "ArduinoJson" by Benoit Blanchon  (v6.x)
//   (WiFi.h and HTTPClient.h ship with the ESP32 board package)
// ============================================================

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// ─── WiFi config — EDIT THESE ───────────────────────────────────
const char* WIFI_SSID     = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// ─── Phone app config — EDIT THESE ──────────────────────────────
// Find the phone's IP in the app's Telemetry Source panel.
String PHONE_IP    = "192.168.1.100";
const int PHONE_PORT = 8080;

// ─── Firebase config — EDIT THESE ───────────────────────────────
// See the setup guide, section "Firebase Realtime Database setup",
// for exactly where to find each of these three values.
#define FIREBASE_HOST   "your-project-id-default-rtdb.firebaseio.com" // NO https://, no trailing slash
#define FIREBASE_AUTH   "your-database-secret-here"                    // legacy Database Secret
#define API_KEY         "your-web-api-key-here"                        // Project settings -> General

FirebaseData   fbdo;
FirebaseAuth   auth;
FirebaseConfig config;
bool firebaseReady = false;

// ─── UART link to the UNO ────────────────────────────────────────
// Uses ESP32's hardware Serial2 — RX2=16 (<- UNO TX, THROUGH A VOLTAGE
// DIVIDER, see wiring guide), TX2=17 (-> UNO RX, direct wire is fine).
#define UNO_RX_PIN 16
#define UNO_TX_PIN 17

void setup() {
  Serial.begin(115200); // USB debug console
  Serial2.begin(9600, SERIAL_8N1, UNO_RX_PIN, UNO_TX_PIN); // link to UNO

  Serial.println(F("=== Smart Bus ESP32 Bridge Booting ==="));
  connectWiFi();
  setupFirebase();
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi(); // keep retrying quietly — never blocks anything else
  }

  if (Serial2.available()) {
    String line = Serial2.readStringUntil('\n');
    line.trim();
    if (line.length() > 0) {
      Serial.print(F("UNO -> "));
      Serial.println(line);
      handleLine(line);
    }
  }
}

// ==============================================================
//  WIFI
// ==============================================================
void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;
  Serial.print(F("Connecting to WiFi"));
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 40) {
    delay(500);
    Serial.print('.');
    attempts++;
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println();
    Serial.print(F("WiFi connected. ESP32 IP: "));
    Serial.println(WiFi.localIP());
  } else {
    Serial.println(F("\nWiFi connect failed — will keep retrying in loop()."));
  }
}

// ==============================================================
//  FIREBASE
// ==============================================================
void setupFirebase() {
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  config.api_key = API_KEY;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  fbdo.setResponseSize(2048);
  firebaseReady = true;
  Serial.println(F("Firebase initialized."));
}

// ==============================================================
//  LINE PARSING
//  Formats sent by the UNO:
//    EVT|type|uid|name|stopName|fare|balance
//    STP|stopNum|stopName|moving(0/1)
// ==============================================================
void handleLine(const String& line) {
  int firstBar = line.indexOf('|');
  if (firstBar == -1) return;
  String kind = line.substring(0, firstBar);
  String rest = line.substring(firstBar + 1);

  if (kind == "EVT") {
    handleEvent(rest);
  } else if (kind == "STP") {
    handleStop(rest);
  }
}

// Splits "a|b|c|d|e" into up to 6 fields.
void splitFields(const String& s, String out[], int maxFields) {
  int start = 0;
  int idx = 0;
  while (idx < maxFields) {
    int bar = s.indexOf('|', start);
    if (bar == -1) {
      out[idx++] = s.substring(start);
      break;
    }
    out[idx++] = s.substring(start, bar);
    start = bar + 1;
  }
}

void handleEvent(const String& rest) {
  String f[6];
  splitFields(rest, f, 6);
  String type = f[0], uid = f[1], name = f[2], stopName = f[3];
  int fare = f[4].toInt();
  int balance = f[5].toInt();

  // 1) forward to the phone app (existing route, no app changes needed)
  postToPhone("/api/bus/event", [&](JsonDocument& doc) {
    doc["uid"] = uid;
    doc["name"] = name;
    doc["type"] = type;
    doc["stop"] = stopName;
    doc["fare"] = fare;
    doc["balance"] = balance;
  });

  // 2) mirror to Firebase Realtime Database
  if (firebaseReady && Firebase.ready()) {
    String path = "/smart_bus/events"; // push -> auto-generated timestamp-ordered key
    FirebaseJson json;
    json.set("type", type);
    json.set("uid", uid);
    json.set("name", name);
    json.set("stop", stopName);
    json.set("fare", fare);
    json.set("balance", balance);
    json.set("timestamp/.sv", "timestamp"); // Firebase server-side timestamp
    if (!Firebase.RTDB.pushJSON(&fbdo, path.c_str(), &json)) {
      Serial.print(F("Firebase event push failed: "));
      Serial.println(fbdo.errorReason());
    }
  }
}

void handleStop(const String& rest) {
  String f[4];
  splitFields(rest, f, 4);
  int stopNum = f[0].toInt();
  String stopName = f[1];
  bool moving = f[2].toInt() == 1;

  // 1) forward to the phone app
  postToPhone("/api/bus/stop", [&](JsonDocument& doc) {
    doc["stopNum"] = stopNum;
    doc["stopName"] = stopName;
    doc["moving"] = moving;
  });

  // 2) mirror to Firebase — this one OVERWRITES a single "current status"
  // node (not a growing list) since only the latest position matters.
  if (firebaseReady && Firebase.ready()) {
    FirebaseJson json;
    json.set("stopNum", stopNum);
    json.set("stopName", stopName);
    json.set("moving", moving);
    json.set("lastUpdated/.sv", "timestamp");
    if (!Firebase.RTDB.setJSON(&fbdo, "/smart_bus/status", &json)) {
      Serial.print(F("Firebase status update failed: "));
      Serial.println(fbdo.errorReason());
    }
  }
}

// ==============================================================
//  HTTP TO PHONE — short timeout, never blocks the UART read loop
// ==============================================================
template <typename BuildFn>
void postToPhone(const char* path, BuildFn buildBody) {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  String url = "http://" + PHONE_IP + ":" + String(PHONE_PORT) + path;
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  http.setTimeout(1500);

  StaticJsonDocument<256> doc;
  buildBody(doc);
  String body;
  serializeJson(doc, body);

  int code = http.POST(body);
  if (code <= 0) {
    Serial.print(F("Phone POST failed: "));
    Serial.println(http.errorToString(code));
  }
  http.end();
}
