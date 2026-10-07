/*
 * =====================================================================================
 * PROJECT    : SMART BUS IOT & AUTOMATIC FARE COLLECTION (FULL PRODUCTION FIRMWARE)
 * PLATFORM   : ARDUINO UNO (9600 BAUD BI-DIRECTIONAL LINK)
 * =====================================================================================
 * CONFIRMED HARDWARE PIN CONNECTIONS:
 *  1. 16x2 I2C LCD     : SDA -> A4 | SCL -> A5 | VCC -> 5V | GND -> GND
 *  2. DFPlayer Mini    : TX -> Pin D2 | RX <- Pin D3 (via 1k resistor) | VCC -> 5V | GND -> GND
 *  3. SG90 Servo Gate  : Signal -> Pin D4 | VCC -> 5V | GND -> GND
 *  4. DC Motor Driver  : IN1 -> Pin D5 | IN2 -> Pin D6 | ENA -> Pin D7 (or 5V)
 *  5. MFRC522 RFID     : SDA(SS)-> D10 | RST-> D9 | MOSI-> D11 | MISO-> D12 | SCK-> D13 (3.3V ONLY!)
 *  6. Push Buttons     : START -> Pin A0 (to GND) | STOP -> Pin A1 (to GND)
 *  7. NodeMCU Bridge   : TX -> Pin A2 (to NodeMCU D2 via 1k/2k divider) | RX <- Pin A3 (from NodeMCU D7) | Common GND
 * =====================================================================================
 * DFPLAYER AUDIO TRACK MAPPING (FOLDER 02 - ENGLISH):
 *  - Track 002.mp3 : "Please tap your card." (Reminder at every stop)
 *  - Track 003.mp3 : "Entry successful. Welcome aboard." (Valid Entry -> Gate 90 deg -> Green LED)
 *  - Track 004.mp3 : "Exit successful. Thank you for travelling with us." (Valid Exit -> Gate 90 deg -> Green LED)
 *  - Track 005.mp3 : "Invalid card. Please try again." (Blocked / Unregistered -> Red LED)
 *  - Track 006.mp3 : "Insufficient balance. Please recharge your card." (Low Balance < Rs.10 -> Red LED)
 *  - Track 007.mp3 to 024.mp3 : Stop 1 (Kempegowda BS) to Stop 18 (16th Main BTM Layout)
 * =====================================================================================
 */

#include <SPI.h>
#include <MFRC522.h>
#include <SoftwareSerial.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Servo.h>
#include <avr/pgmspace.h>

// --- PIN DEFINITIONS ---
#define PIN_DF_RX      2   // Receives from DFPlayer TX
#define PIN_DF_TX      3   // Transmits to DFPlayer RX via 1k resistor
#define PIN_SERVO      4   // SG90 Gate Servo on D4
#define PIN_MOTOR_IN1  5   // DC Motor IN1
#define PIN_MOTOR_IN2  6   // DC Motor IN2
#define PIN_MOTOR_ENA  7   // DC Motor ENA
#define PIN_RFID_RST   9   // MFRC522 Reset
#define PIN_RFID_SS    10  // MFRC522 SDA / SS
#define PIN_START_BTN  A0  // START Button (Active LOW)
#define PIN_STOP_BTN   A1  // STOP Button (Active LOW)
#define PIN_NODE_TX    A2  // Telemetry TX to NodeMCU D2 (via divider)
#define PIN_NODE_RX    A3  // Command RX from NodeMCU D7

// --- VOLUME CONFIGURATION ---
#define DF_VOLUME      30  // 30 = Maximum Volume (Range: 0-30)

// --- OBJECTS ---
SoftwareSerial dfSerial(PIN_DF_RX, PIN_DF_TX);       // D2 (RX), D3 (TX)
SoftwareSerial nodeSerial(PIN_NODE_RX, PIN_NODE_TX); // A3 (RX), A2 (TX)
LiquidCrystal_I2C lcd(0x27, 16, 2);
MFRC522 rfid(PIN_RFID_SS, PIN_RFID_RST);
Servo gateServo;

// --- PASSENGER DATABASE (DYNAMIC CAPACITY: UP TO 15 CARDS) ---
struct Passenger {
  byte uid[4];
  char name[12];
  int balance;
  bool isInside;
  int entryStop;
  bool isBlocked;
};

#define MAX_PASSENGERS 15
int numPassengers = 7;

Passenger passengers[MAX_PASSENGERS] = {
  {{0x54, 0x02, 0xBB, 0xA9}, "Bhanu",     10,  false, 0, false}, // Valid Card (Active: Rs.10 starting balance)
  {{0x63, 0xE6, 0xD5, 0x1D}, "Karthik",   200, false, 0, false}, // Valid Card (Active)
  {{0xF0, 0xC2, 0x7F, 0x5F}, "Gayathri",  200, false, 0, false}, // Valid Card (Active)
  {{0x90, 0x44, 0x44, 0x55}, "Nharika",   200, false, 0, false}, // Valid Card (Active)
  {{0x5B, 0x85, 0x0B, 0x1A}, "Kanthesh",  200, false, 0, false}, // Valid Card (Active)
  {{0x3D, 0x08, 0x50, 0x06}, "Shyamala",  5,   false, 0, false}, // Low Balance (< Rs.10)
  {{0x21, 0xDB, 0x3E, 0x0A}, "Prema",     50,  false, 0, true}   // Inactive/Blocked by default
};

// --- ROUTE STOPS STORED IN PROGMEM ---
const char s01_1[] PROGMEM = "S01:KempegowdaBS"; const char s01_2[] PROGMEM = "TERMINAL START  ";
const char s02_1[] PROGMEM = "S02:Maharani Col"; const char s02_2[] PROGMEM = "NEXT STOP >>    ";
const char s03_1[] PROGMEM = "S03:K. R. Circle"; const char s03_2[] PROGMEM = "NEXT STOP >>    ";
const char s04_1[] PROGMEM = "S04:St Marthas  "; const char s04_2[] PROGMEM = "HOSPITAL AHEAD  ";
const char s05_1[] PROGMEM = "S05:Corporation "; const char s05_2[] PROGMEM = "CIRCLE AHEAD >> ";
const char s06_1[] PROGMEM = "S06:Poornima Tlk"; const char s06_2[] PROGMEM = "THEATRE AHEAD   ";
const char s07_1[] PROGMEM = "S07:Lalbagh Main"; const char s07_2[] PROGMEM = "MAIN GATE STOP  ";
const char s08_1[] PROGMEM = "S08:Lalbagh West"; const char s08_2[] PROGMEM = "WEST GATE STOP  ";
const char s09_1[] PROGMEM = "S09:AshokaPillar"; const char s09_2[] PROGMEM = "HISTORIC PILLAR ";
const char s10_1[] PROGMEM = "S10:Rani Sarala "; const char s10_2[] PROGMEM = "HIGH SCHOOL STOP";
const char s11_1[] PROGMEM = "S11:Jayanagar3rd"; const char s11_2[] PROGMEM = "BLOCK 3 AHEAD >>";
const char s12_1[] PROGMEM = "S12:Jayanagar4th"; const char s12_2[] PROGMEM = "SHOPPING COMPLEX";
const char s13_1[] PROGMEM = "S13:JayanagarChr"; const char s13_2[] PROGMEM = "CHURCH STOP >>  ";
const char s14_1[] PROGMEM = "S14:SanjayGandhi"; const char s14_2[] PROGMEM = "HOSPITAL STOP   ";
const char s15_1[] PROGMEM = "S15:CarmelConvent";const char s15_2[] PROGMEM = "CONVENT STOP >> ";
const char s16_1[] PROGMEM = "S16:Pump House  "; const char s16_2[] PROGMEM = "PUMP HOUSE STOP ";
const char s17_1[] PROGMEM = "S17:East End Jay"; const char s17_2[] PROGMEM = "EAST END STOP   ";
const char s18_1[] PROGMEM = "S18:16th MainBTM"; const char s18_2[] PROGMEM = "FINAL STOP AHEAD";

const char* const stopTableL1[18] PROGMEM = {
  s01_1, s02_1, s03_1, s04_1, s05_1, s06_1,
  s07_1, s08_1, s09_1, s10_1, s11_1, s12_1,
  s13_1, s14_1, s15_1, s16_1, s17_1, s18_1
};

const char* const stopTableL2[18] PROGMEM = {
  s01_2, s02_2, s03_2, s04_2, s05_2, s06_2,
  s07_2, s08_2, s09_2, s10_2, s11_2, s12_2,
  s13_2, s14_2, s15_2, s16_2, s17_2, s18_2
};

#define TOTAL_STOPS 18

// --- SYSTEM STATE ---
int currentStopIndex = 0;
bool isBusRunning = false;
unsigned long lastRfidScanTime = 0;
String cmdBuffer = "";

// --- SEND 10-BYTE DFPLAYER COMMAND ---
void sendDFCommand(uint8_t cmd, uint8_t highByte, uint8_t lowByte) {
  uint8_t packet[10] = {0x7E, 0xFF, 0x06, cmd, 0x00, highByte, lowByte, 0x00, 0x00, 0xEF};
  uint16_t checksum = 0 - (0xFF + 0x06 + cmd + 0x00 + highByte + lowByte);
  packet[7] = (uint8_t)(checksum >> 8);
  packet[8] = (uint8_t)(checksum & 0xFF);

  for (int i = 0; i < 10; i++) {
    dfSerial.write(packet[i]);
  }
  delay(30);
  nodeSerial.listen(); // Always re-arm nodeSerial for incoming commands
}

// --- MOTOR CONTROLS ---
void startMotor() {
  digitalWrite(PIN_MOTOR_IN1, HIGH);
  digitalWrite(PIN_MOTOR_IN2, LOW);
  analogWrite(PIN_MOTOR_ENA, 220);
  Serial.println(F("[MOTOR]: STARTED (Running forward)"));
}

void stopMotor() {
  digitalWrite(PIN_MOTOR_IN1, LOW);
  digitalWrite(PIN_MOTOR_IN2, LOW);
  analogWrite(PIN_MOTOR_ENA, 0);
  Serial.println(F("[MOTOR]: STOPPED"));
}

// --- SERVO GATE CONTROL (PIN D4) ---
void openGate() {
  Serial.println(F("[SERVO GATE]: OPENING TO 90 DEGREES..."));
  gateServo.write(90);
  delay(3000); // Gate open 3 seconds
  Serial.println(F("[SERVO GATE]: CLOSING TO 0 DEGREES..."));
  gateServo.write(0);
}

// --- COMPARE RFID UID ---
bool isUidEqual(byte* u1, byte* u2) {
  for (int i = 0; i < 4; i++) {
    if (u1[i] != u2[i]) return false;
  }
  return true;
}

// --- HEX CONVERSION HELPERS ---
byte hexVal(char c) {
  if (c >= '0' && c <= '9') return c - '0';
  if (c >= 'A' && c <= 'F') return c - 'A' + 10;
  if (c >= 'a' && c <= 'f') return c - 'a' + 10;
  return 0;
}

void parseHexUid(const String& str, byte* out) {
  String clean = str;
  clean.replace(" ", "");
  clean.toUpperCase();
  for (int i = 0; i < 4; i++) {
    if (i * 2 + 1 < clean.length()) {
      out[i] = (hexVal(clean.charAt(i * 2)) << 4) | hexVal(clean.charAt(i * 2 + 1));
    } else {
      out[i] = 0;
    }
  }
}

bool isUidMatchStr(const String& uidStr, byte* u) {
  char buf[9];
  sprintf(buf, "%02X%02X%02X%02X", u[0], u[1], u[2], u[3]);
  return uidStr.equalsIgnoreCase(String(buf));
}

// --- SEND TELEMETRY PACKET TO NODEMCU ---
void sendTelemetry(const char* eventType, int stopNum, int balance, byte* uidBytes, const char* name, int fare) {
  String uidStr = "";
  if (uidBytes != NULL) {
    for (int i = 0; i < 4; i++) {
      if (uidBytes[i] < 0x10) uidStr += "0";
      uidStr += String(uidBytes[i], HEX);
    }
    uidStr.toUpperCase();
  }

  // Format: EVENT,STOP,BALANCE,UID,NAME,FARE
  nodeSerial.print(eventType);
  nodeSerial.print(F(","));
  nodeSerial.print(stopNum);
  nodeSerial.print(F(","));
  nodeSerial.print(balance);
  nodeSerial.print(F(","));
  nodeSerial.print(uidStr);
  nodeSerial.print(F(","));
  nodeSerial.print(name);
  nodeSerial.print(F(","));
  nodeSerial.println(fare);

  Serial.print(F("[TELEMETRY -> NODEMCU]: "));
  Serial.print(eventType);
  Serial.print(F(" | Stop: "));
  Serial.print(stopNum);
  Serial.print(F(" | User: "));
  Serial.print(name);
  Serial.print(F(" | Bal: "));
  Serial.print(balance);
  Serial.print(F(" | Fare: "));
  Serial.println(fare);
}

// --- RESTORE LCD PROMPT ---
void restoreLcd() {
  if (isBusRunning) {
    char l1[17];
    strcpy_P(l1, (char*)pgm_read_ptr(&(stopTableL1[currentStopIndex])));
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(l1);
    lcd.setCursor(0, 1);
    lcd.print(F("BUS IN TRANSIT>>"));
  } else {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(F("PLEASE TAP CARD "));
    lcd.setCursor(0, 1);
    lcd.print(F("TOUCH RFID HERE "));
  }
}

// --- ANNOUNCE NEXT STOP WHILE MOTOR RUNS ---
void announceNextStop(int stopIdx) {
  char l1[17];
  char l2[17];
  strcpy_P(l1, (char*)pgm_read_ptr(&(stopTableL1[stopIdx])));
  strcpy_P(l2, (char*)pgm_read_ptr(&(stopTableL2[stopIdx])));

  // 1. Update LCD immediately
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(l1);
  lcd.setCursor(0, 1);
  lcd.print(l2);

  // 2. Map Stop to MP3 Track (Stop 1 = 007.mp3 ... Stop 18 = 024.mp3)
  uint8_t track = (uint8_t)(stopIdx + 7);

  Serial.println(F("\n========================================"));
  Serial.print(F(">>> [BUS RUNNING] -> NEXT STOP: "));
  Serial.println(l1);
  Serial.print(F(">>> [AUDIO] : Playing Stop Track "));
  Serial.print(track);
  Serial.println(F(".mp3 (Folder 02)"));

  // 3. Send START telemetry to NodeMCU
  sendTelemetry("START", stopIdx + 1, 0, NULL, l1, 0);

  // 4. Play Stop Announcement in background while motor runs
  sendDFCommand(0x0F, 2, track);
}

// --- PROCESS COMMAND FROM NODEMCU ---
void processNodeMcuCommand(String cmd) {
  cmd.trim();
  if (cmd.length() == 0) return;

  Serial.print(F("\n>>> [COMMAND RECEIVED FROM NODEMCU]: "));
  Serial.println(cmd);

  // --- 1. DYNAMIC REGISTRATION: REGISTER,UID,NAME,BALANCE ---
  if (cmd.startsWith("REGISTER,")) {
    int c1 = cmd.indexOf(',');
    int c2 = cmd.indexOf(',', c1 + 1);
    int c3 = cmd.indexOf(',', c2 + 1);
    if (c1 != -1 && c2 != -1 && c3 != -1) {
      String uidStr = cmd.substring(c1 + 1, c2);
      String name   = cmd.substring(c2 + 1, c3);
      int balance   = cmd.substring(c3 + 1).toInt();
      uidStr.trim();
      uidStr.toUpperCase();
      name.trim();

      int foundIdx = -1;
      for (int i = 0; i < numPassengers; i++) {
        if (isUidMatchStr(uidStr, passengers[i].uid)) {
          foundIdx = i;
          break;
        }
      }

      if (foundIdx != -1) {
        name.toCharArray(passengers[foundIdx].name, sizeof(passengers[foundIdx].name));
        passengers[foundIdx].balance = balance;
        passengers[foundIdx].isBlocked = false;
        passengers[foundIdx].isInside = false;
      } else if (numPassengers < MAX_PASSENGERS) {
        foundIdx = numPassengers;
        parseHexUid(uidStr, passengers[foundIdx].uid);
        name.toCharArray(passengers[foundIdx].name, sizeof(passengers[foundIdx].name));
        passengers[foundIdx].balance = balance;
        passengers[foundIdx].isInside = false;
        passengers[foundIdx].entryStop = 0;
        passengers[foundIdx].isBlocked = false;
        numPassengers++;
      }

      Serial.print(F(">>> [DYNAMIC REGISTRATION SUCCESS]: "));
      Serial.print(name);
      Serial.print(F(" (UID "));
      Serial.print(uidStr);
      Serial.print(F(") | Bal: Rs."));
      Serial.println(balance);

      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print(F("CARD REGISTERED!"));
      lcd.setCursor(0, 1);
      lcd.print(name);
      lcd.print(F(" Bal:Rs."));
      lcd.print(balance);
      delay(2000);
      restoreLcd();
    }
  }
  // --- 2. RECHARGE COMMAND: RECHARGE,UID,AMOUNT ---
  else if (cmd.startsWith("RECHARGE,")) {
    int c1 = cmd.indexOf(',');
    int c2 = cmd.indexOf(',', c1 + 1);
    if (c1 != -1 && c2 != -1) {
      String uidStr = cmd.substring(c1 + 1, c2);
      int amount    = cmd.substring(c2 + 1).toInt();
      uidStr.trim();
      uidStr.toUpperCase();

      for (int i = 0; i < numPassengers; i++) {
        if (isUidMatchStr(uidStr, passengers[i].uid)) {
          passengers[i].balance += amount; // e.g. 5 + 100 = 105
          Serial.print(F(">>> [RECHARGE SUCCESSFUL]: "));
          Serial.print(passengers[i].name);
          Serial.print(F(" +Rs."));
          Serial.print(amount);
          Serial.print(F(" | New Balance = Rs."));
          Serial.println(passengers[i].balance);

          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print(F("RECHARGE SUCCESS"));
          lcd.setCursor(0, 1);
          lcd.print(passengers[i].name);
          lcd.print(F(" +Rs."));
          lcd.print(amount);
          delay(2000);
          restoreLcd();
          break;
        }
      }
    }
  }
  // --- 3. CARD STATUS COMMAND: CARDSTATUS,UID,STATUS or CARD_STATUS,UID,STATUS (1 = Active, 0 = Inactive/Blocked) ---
  else if (cmd.startsWith("CARDSTATUS,") || cmd.startsWith("CARD_STATUS,")) {
    int c1 = cmd.indexOf(',');
    int c2 = cmd.indexOf(',', c1 + 1);
    if (c1 != -1 && c2 != -1) {
      String uidStr = cmd.substring(c1 + 1, c2);
      String statusStr = cmd.substring(c2 + 1);
      uidStr.trim();
      uidStr.toUpperCase();
      statusStr.trim();
      statusStr.toUpperCase();

      bool blocked = false;
      if (statusStr == "0" || statusStr == "BLOCKED" || statusStr == "DEACTIVATE" || statusStr == "INACTIVATE" || statusStr == "FALSE" || statusStr == "LOCK") {
        blocked = true;
      } else if (statusStr == "1" || statusStr == "ACTIVE" || statusStr == "ACTIVATE" || statusStr == "TRUE" || statusStr == "READY") {
        blocked = false;
      } else {
        blocked = (statusStr.toInt() == 0);
      }

      int foundIdx = -1;
      for (int i = 0; i < numPassengers; i++) {
        if (isUidMatchStr(uidStr, passengers[i].uid)) {
          foundIdx = i;
          break;
        }
      }

      if (foundIdx == -1 && numPassengers < MAX_PASSENGERS) {
        foundIdx = numPassengers;
        parseHexUid(uidStr, passengers[foundIdx].uid);
        strcpy(passengers[foundIdx].name, "Passenger");
        passengers[foundIdx].balance = 200;
        passengers[foundIdx].isInside = false;
        passengers[foundIdx].entryStop = 0;
        passengers[foundIdx].isBlocked = blocked;
        numPassengers++;
      }

      if (foundIdx != -1) {
        passengers[foundIdx].isBlocked = blocked;
        Serial.print(F(">>> [STATUS CHANGED]: "));
        Serial.print(passengers[foundIdx].name);
        Serial.println(blocked ? F(" is now INACTIVE / BLOCKED") : F(" is now ACTIVE"));

        lcd.clear();
        lcd.setCursor(0, 0);
        if (blocked) {
          lcd.print(F("CARD BLOCKED!   "));
          lcd.setCursor(0, 1);
          lcd.print(passengers[foundIdx].name);
          lcd.print(F(" [LOCKED]"));
        } else {
          lcd.print(F("CARD ACTIVATED! "));
          lcd.setCursor(0, 1);
          lcd.print(passengers[foundIdx].name);
          lcd.print(F(" [ACTIVE]"));
        }
        delay(2000);
        restoreLcd();
      }
    }
  }
}

// --- FAST NON-BLOCKING SERIAL RECEIVER ---
void handleNodeMcuCommands() {
  while (nodeSerial.available() > 0) {
    char c = (char)nodeSerial.read();
    if (c == '\n' || c == '\r') {
      if (cmdBuffer.length() > 0) {
        processNodeMcuCommand(cmdBuffer);
        cmdBuffer = "";
      }
    } else {
      if (cmdBuffer.length() < 60) {
        cmdBuffer += c;
      }
    }
  }
}

// --- RFID PASSENGER SCAN HANDLER ---
void handleRfid() {
  if (!rfid.PICC_IsNewCardPresent()) {
    return;
  }
  if (!rfid.PICC_ReadCardSerial()) {
    return;
  }

  if (millis() - lastRfidScanTime < 1500) {
    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();
    return;
  }
  lastRfidScanTime = millis();

  byte* scannedUid = rfid.uid.uidByte;

  Serial.println(F("\n========================================"));
  Serial.print(F(">>> [RFID SCANNED]: UID = "));
  for (byte i = 0; i < rfid.uid.size; i++) {
    if (scannedUid[i] < 0x10) Serial.print('0');
    Serial.print(scannedUid[i], HEX);
    Serial.print(' ');
  }
  Serial.println();
  Serial.println(F("========================================"));

  // Search in database (Includes dynamically registered cards!)
  int pIdx = -1;
  for (int i = 0; i < numPassengers; i++) {
    if (isUidEqual(passengers[i].uid, scannedUid)) {
      pIdx = i;
      break;
    }
  }

  // --- 1. UNREGISTERED / UNKNOWN CARD ---
  if (pIdx == -1) {
    Serial.println(F("    [STATUS]: UNREGISTERED CARD -> Access Denied"));
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(F("INVALID CARD!   "));
    lcd.setCursor(0, 1);
    lcd.print(F("ACCESS DENIED   "));

    // Track 005.mp3 -> "Invalid card. Please try again."
    sendDFCommand(0x0F, 2, 5);
    sendTelemetry("INVALID", currentStopIndex + 1, 0, scannedUid, "Unknown", 0);
    delay(3000);
    restoreLcd();
  }
  // --- 2. DEACTIVATED / INACTIVE / BLOCKED CARD ---
  else if (passengers[pIdx].isBlocked) {
    Serial.print(F("    [STATUS]: CARD INACTIVE / BLOCKED -> "));
    Serial.println(passengers[pIdx].name);

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(F("CARD BLOCKED!   "));
    lcd.setCursor(0, 1);
    lcd.print(passengers[pIdx].name);
    lcd.print(F(" [DENIED]"));

    // Track 005.mp3 -> "Invalid card. Please try again."
    sendDFCommand(0x0F, 2, 5);
    sendTelemetry("DEACTIVATED", currentStopIndex + 1, passengers[pIdx].balance, scannedUid, passengers[pIdx].name, 0);
    delay(3000);
    restoreLcd();
  }
  // --- 3. VALID ENTRY (Passenger is Outside) ---
  else if (!passengers[pIdx].isInside) {
    if (passengers[pIdx].balance < 10) {
      Serial.print(F("    [STATUS]: LOW BALANCE -> Rs."));
      Serial.println(passengers[pIdx].balance);

      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print(F("LOW BALANCE!    "));
      lcd.setCursor(0, 1);
      lcd.print(F("PLEASE RECHARGE "));

      // Track 006.mp3 -> "Insufficient balance. Please recharge."
      sendDFCommand(0x0F, 2, 6);
      sendTelemetry("LOWBAL", currentStopIndex + 1, passengers[pIdx].balance, scannedUid, passengers[pIdx].name, 0);
      delay(3000);
      restoreLcd();
    } else {
      passengers[pIdx].isInside = true;
      passengers[pIdx].entryStop = currentStopIndex;

      Serial.print(F("    [STATUS]: ENTRY APPROVED -> "));
      Serial.println(passengers[pIdx].name);

      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print(F("ENTRY SUCCESSFUL"));
      lcd.setCursor(0, 1);
      lcd.print(passengers[pIdx].name);
      lcd.print(F(" Bal:Rs."));
      lcd.print(passengers[pIdx].balance);

      // Track 003.mp3 -> "Entry successful. Welcome aboard."
      sendDFCommand(0x0F, 2, 3);
      sendTelemetry("ENTRY", currentStopIndex + 1, passengers[pIdx].balance, scannedUid, passengers[pIdx].name, 0);

      // Open gate for 3.0s (Green LED on NodeMCU)
      openGate();
      restoreLcd();
    }
  }
  // --- 4. VALID EXIT (Passenger is Inside) ---
  else {
    int stopsTravelled = currentStopIndex - passengers[pIdx].entryStop;
    if (stopsTravelled <= 0) stopsTravelled = 1;

    int fare = stopsTravelled * 10; // Rs. 10 per stop
    if (passengers[pIdx].balance >= fare) {
      passengers[pIdx].balance -= fare;
    } else {
      fare = passengers[pIdx].balance;
      passengers[pIdx].balance = 0;
    }
    passengers[pIdx].isInside = false;

    Serial.print(F("    [STATUS]: EXIT APPROVED -> "));
    Serial.print(passengers[pIdx].name);
    Serial.print(F(" | Fare: Rs."));
    Serial.print(fare);
    Serial.print(F(" | Remaining Bal: Rs."));
    Serial.println(passengers[pIdx].balance);

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(F("EXIT SUCCESSFUL "));
    lcd.setCursor(0, 1);
    lcd.print(F("Fare:"));
    lcd.print(fare);
    lcd.print(F(" Bal:Rs."));
    lcd.print(passengers[pIdx].balance);

    // Track 004.mp3 -> "Exit successful. Fare deducted."
    sendDFCommand(0x0F, 2, 4);
    sendTelemetry("EXIT", currentStopIndex + 1, passengers[pIdx].balance, scannedUid, passengers[pIdx].name, fare);

    // Open gate for 3.0s (Green LED on NodeMCU)
    openGate();
    restoreLcd();
  }

  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();
}

// --- BUTTON LOGIC ---
void handleButtons() {
  // START BUTTON (A0) -> Start Bus
  if (digitalRead(PIN_START_BTN) == LOW) {
    delay(50); // Debounce
    if (digitalRead(PIN_START_BTN) == LOW) {
      if (!isBusRunning) {
        isBusRunning = true;
        currentStopIndex = (currentStopIndex + 1) % TOTAL_STOPS;
        startMotor();
        announceNextStop(currentStopIndex);
      }
      while (digitalRead(PIN_START_BTN) == LOW) {
        handleNodeMcuCommands();
        delay(10);
      }
    }
  }

  // STOP BUTTON (A1) -> Stop Bus at Current Stop
  if (digitalRead(PIN_STOP_BTN) == LOW) {
    delay(50); // Debounce
    if (digitalRead(PIN_STOP_BTN) == LOW) {
      if (isBusRunning) {
        isBusRunning = false;
        stopMotor();

        char l1[17];
        strcpy_P(l1, (char*)pgm_read_ptr(&(stopTableL1[currentStopIndex])));

        Serial.println(F("\n========================================"));
        Serial.print(F(">>> [BUS STOPPED] -> ARRIVED AT: "));
        Serial.println(l1);

        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print(l1);
        lcd.setCursor(0, 1);
        lcd.print(F("BUS AT STOP     "));

        // Audio Track: Stop 1 = 007.mp3 ... Stop 18 = 024.mp3
        uint8_t track = (uint8_t)(currentStopIndex + 7);
        sendDFCommand(0x0F, 2, track);

        sendTelemetry("STOP", currentStopIndex + 1, 0, NULL, l1, 0);
        delay(2000);
        restoreLcd();
      }
      while (digitalRead(PIN_STOP_BTN) == LOW) {
        handleNodeMcuCommands();
        delay(10);
      }
    }
  }
}

// --- SETUP ---
void setup() {
  Serial.begin(9600);
  dfSerial.begin(9600);
  nodeSerial.begin(9600);

  pinMode(PIN_START_BTN, INPUT_PULLUP);
  pinMode(PIN_STOP_BTN, INPUT_PULLUP);
  pinMode(PIN_NODE_RX, INPUT_PULLUP); // Arduino A3 Pullup for NodeMCU TX
  pinMode(PIN_MOTOR_IN1, OUTPUT);
  pinMode(PIN_MOTOR_IN2, OUTPUT);
  pinMode(PIN_MOTOR_ENA, OUTPUT);
  stopMotor();

  gateServo.attach(PIN_SERVO);
  gateServo.write(0); // Start Closed (0 degrees)

  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(F("SMART BUS SYSTEM"));
  lcd.setCursor(0, 1);
  lcd.print(F("INITIALIZING... "));

  SPI.begin();
  rfid.PCD_Init();

  Serial.println(F("\n========================================================"));
  Serial.println(F(" SMART BUS IOT & AFC SYSTEM - ARDUINO FIRMWARE (9600 BAUD)"));
  Serial.println(F("========================================================"));

  // Initialize DFPlayer Volume & Select TF Card
  delay(500);
  sendDFCommand(0x09, 0, 2); // Select TF Card
  delay(100);
  sendDFCommand(0x06, 0, DF_VOLUME); // Set volume (30)
  delay(100);

  // Play Initial Stop 1 Announcement (Kempegowda Bus Station)
  sendDFCommand(0x0F, 2, 7); // Track 007.mp3: Kempegowda Bus Station

  nodeSerial.listen();

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(F("S01:KempegowdaBS"));
  lcd.setCursor(0, 1);
  lcd.print(F("TERMINAL START  "));
  delay(2000);
  restoreLcd();
}

// --- MAIN LOOP ---
void loop() {
  handleNodeMcuCommands();
  handleButtons();
  handleRfid();
}
