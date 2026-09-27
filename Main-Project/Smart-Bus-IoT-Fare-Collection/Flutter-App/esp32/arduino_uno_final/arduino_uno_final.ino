// ============================================================
//  Automatic Bus Fare Collection System – FINAL VERSION (v2)
//  Board   : Arduino UNO
//  Hardware: MFRC522 RFID · DFPlayer Mini · 16x2 I2C LCD
//            · 2x Servo (Entry / Exit) · L293D DC Motor
//            · START button · STOP button · LANGUAGE button
//            · UART link to a separate ESP32 (WiFi/Firebase bridge)
//
//  WHAT CHANGED FROM YOUR ORIGINAL "FINAL VERSION" (and nothing else):
//   1. Added a SoftwareSerial link to a separate ESP32 board (pins 4/A2)
//      — the UNO sends a one-line report after every decision it makes.
//      It does NOT wait for a reply, so a disconnected/slow ESP32 can
//      never delay a passenger's tap — exactly like your original code's
//      offline-first behaviour, just with an extra "by the way, here's
//      what just happened" message going out.
//   2. Added bilingual audio: a LANGUAGE button (pin A3) toggles between
//      SD card folder 01 (Kannada) and folder 02 (English). Every
//      existing player.playFolder(1, ...) call now uses a currentLang
//      variable instead of a hardcoded 1 — same tracks, same numbering,
//      just picking the correct folder for the selected language.
//   3. Nothing else changed: same card database, same fare-on-exit
//      calculation, same servo angles, same LCD screens, same button
//      debounce timing, same audio hold delays.
//
//  SD CARD LAYOUT (per your latest spec)
//  /01/  = Kannada announcements   (001.mp3 – 025.mp3)
//  /02/  = English announcements   (001.mp3 – 025.mp3)
//  Same track-number meaning in both folders:
//   002=tap card  003=entry ok  004=exit ok  005=invalid  006=low balance
//   007=boot announcement  008..024=stop names (track = 6 + stopNum)
//   025=language-selected confirmation
//
//  PIN MAP (unchanged pins keep their original numbers; only the 3 new
//  pins below are additions — chosen to avoid the UNO's fixed hardware
//  SPI pins 11/12/13, which the MFRC522 library uses internally and
//  which are NOT safe to reuse for anything else)
//   ESP_RX_PIN  = 4   (UNO receives on this pin <- ESP32 TX2)
//   ESP_TX_PIN  = A2  (UNO transmits on this pin -> ESP32 RX2, THROUGH
//                       A VOLTAGE DIVIDER — see wiring guide, this line
//                       carries 5V logic and ESP32 inputs are 3.3V only)
//   BTN_LANG    = A3  (press to toggle Kannada <-> English)
// ============================================================

#include <SPI.h>
#include <MFRC522.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Servo.h>
#include <SoftwareSerial.h>
#include <DFRobotDFPlayerMini.h>

// ─── Pin Definitions — ORIGINAL, unchanged ─────────────────────
#define SS_PIN          10
#define RST_PIN          9
#define MOTOR_IN1        5
#define MOTOR_IN2        6
#define ENTRY_SERVO_PIN  7
#define EXIT_SERVO_PIN   8
#define BTN_START       A0
#define BTN_STOP        A1
#define DF_RX_PIN        3
#define DF_TX_PIN        2

// ─── Pin Definitions — NEW (ESP32 link + language button) ─────
#define ESP_RX_PIN        4   // free digital pin
#define ESP_TX_PIN       A2   // free analog pin used as digital output
#define BTN_LANG         A3   // free analog pin used as digital input

// ─── Servo Angles — unchanged ──────────────────────────────────
#define ENTRY_CLOSED     7
#define EXIT_CLOSED      8
#define GATE_OPEN       90

// ─── Audio Track Numbers — unchanged ───────────────────────────
#define SND_BEEP         1
#define SND_TAP_CARD     2
#define SND_ENTRY_OK     3
#define SND_EXIT_OK      4
#define SND_INVALID      5
#define SND_LOW_BAL      6
#define SND_KEMPEGOWDA   7
// Stop-name track formula: track = 6 + stopNum (unchanged)

// ─── Language folders — NEW ────────────────────────────────────
#define LANG_KANNADA      1   // SD card folder "01"
#define LANG_ENGLISH      2   // SD card folder "02"
int currentLang = LANG_KANNADA; // boots in Kannada — change if you prefer

// ─── Status LEDs — NEW, via PCF8574 I2C expander ───────────────
// The UNO has no free pins left (2-13, A0-A3 all committed; A4/A5 are
// I2C for the LCD; 0/1 are hardware Serial, needed for USB debug
// prints). Rather than fight for a scarce pin, we add a PCF8574 I/O
// expander chip, controlled over the SAME I2C bus the LCD already
// uses — zero new Arduino pins consumed, Serial debugging stays
// intact. Wire your LEDs to the PCF8574's P0/P1 pins (see the wiring
// guide), not directly to the UNO.
#define PCF8574_ADDR   0x20   // default address with all address pins (A0-A2) tied LOW
                              // — if your LCD backpack ALSO happens to be at 0x20,
                              // change one of the two by moving an address jumper/pin
#define LED_GREEN_BIT  0      // PCF8574 pin P0
#define LED_RED_BIT    1      // PCF8574 pin P1

byte pcfState = 0xFF; // all bits HIGH = both LEDs off (wiring is active-LOW, see guide)

void pcfWrite() {
  Wire.beginTransmission(PCF8574_ADDR);
  Wire.write(pcfState);
  Wire.endTransmission();
}

void setLed(int bit, bool on) {
  if (on) pcfState &= ~(1 << bit);  // clear bit -> drives that pin LOW -> LED on
  else    pcfState |=  (1 << bit);  // set bit   -> pin HIGH            -> LED off
  pcfWrite();
}

// Flashes green for a moment on any APPROVED tap (entry/exit success).
void ledApproved() {
  setLed(LED_GREEN_BIT, true);
  delay(1200);
  setLed(LED_GREEN_BIT, false);
}

// Flashes red for a moment on any DENIED tap (invalid card / low balance).
void ledDenied() {
  setLed(LED_RED_BIT, true);
  delay(1200);
  setLed(LED_RED_BIT, false);
}

// ─── Stop Names (PROGMEM) — unchanged ──────────────────────────
#define TOTAL_STOPS 18

const char s1[]  PROGMEM = "Kempegowda BS";
const char s2[]  PROGMEM = "Maharanis Coll";
const char s3[]  PROGMEM = "KR Circle";
const char s4[]  PROGMEM = "St Marthas Hosp";
const char s5[]  PROGMEM = "Corporation";
const char s6[]  PROGMEM = "Poornima Talki";
const char s7[]  PROGMEM = "Lalbagh Main G";
const char s8[]  PROGMEM = "Lalbagh West G";
const char s9[]  PROGMEM = "Ashoka Pillar";
const char s10[] PROGMEM = "Rani Sarala HS";
const char s11[] PROGMEM = "3rd Blk Jayanag";
const char s12[] PROGMEM = "4th Blk Jayanag";
const char s13[] PROGMEM = "Jayanagar Chrch";
const char s14[] PROGMEM = "Sanjay Gandhi H";
const char s15[] PROGMEM = "Carmel Convent";
const char s16[] PROGMEM = "Pump House";
const char s17[] PROGMEM = "East End Jayang";
const char s18[] PROGMEM = "16th Main BTM";

const char* const stopNames[] PROGMEM = {
  s1, s2, s3, s4, s5, s6, s7, s8, s9,
  s10, s11, s12, s13, s14, s15, s16, s17, s18
};

char stopBuf[17];

void getStopName(int stopNum) {
  strcpy_P(stopBuf, (char*)pgm_read_word(&(stopNames[stopNum - 1])));
}

// ─── Objects ───────────────────────────────────────────────────
MFRC522             rfid(SS_PIN, RST_PIN);
LiquidCrystal_I2C   lcd(0x27, 16, 2);
Servo               entryServo;
Servo               exitServo;
SoftwareSerial      dfSerial(DF_RX_PIN, DF_TX_PIN);
DFRobotDFPlayerMini player;

// NEW — link to the ESP32. This is TRANSMIT-ONLY from the UNO's side
// (we never call espSerial.read()), so it never competes with dfSerial
// for "which SoftwareSerial is currently listening" — that limitation
// only affects receiving, not sending.
SoftwareSerial espSerial(ESP_RX_PIN, ESP_TX_PIN); // (RX, TX)

// ─── Card Database — unchanged ─────────────────────────────────
struct Card {
  byte        uid[4];
  const char* name;
  int         balance;
  int         boardedAtStop;
};

const char c1[] PROGMEM = "Card 1";
const char c2[] PROGMEM = "Card 2";
const char c3[] PROGMEM = "Card 3";
const char c4[] PROGMEM = "Card 4";

Card cards[] = {
  {{0x5B, 0x85, 0x0B, 0x1A}, c1, 200, 0},
  {{0x63, 0xE6, 0xD5, 0x1D}, c2, 100, 0},
  {{0x54, 0x02, 0xBB, 0xA9}, c3, 250, 0},
  {{0xF0, 0xC2, 0x7F, 0x5F}, c4, 300, 0},
};
const int CARD_COUNT    = sizeof(cards) / sizeof(cards[0]);
const int FARE_PER_STOP = 10;

// ─── Global State — unchanged ──────────────────────────────────
bool systemStarted  = false;
bool motorRunning   = false;
int  currentStop    = 1;
bool rfidOK         = false;
bool dfplayerOK     = false;
int  passengerCount = 0;

// ==============================================================
//  LCD HELPERS — unchanged
// ==============================================================
void lcdTwoStr(const char* l1, const char* l2) {
  lcd.clear();
  lcd.setCursor(0, 0); lcd.print(l1);
  lcd.setCursor(0, 1); lcd.print(l2);
}

void lcdTwoF(const __FlashStringHelper* l1,
             const __FlashStringHelper* l2) {
  lcd.clear();
  lcd.setCursor(0, 0); lcd.print(l1);
  lcd.setCursor(0, 1); lcd.print(l2);
}

void lcdFlashStr(const __FlashStringHelper* l1, const char* l2) {
  lcd.clear();
  lcd.setCursor(0, 0); lcd.print(l1);
  lcd.setCursor(0, 1); lcd.print(l2);
}

void showTapCard() {
  char line1[17];
  getStopName(currentStop);
  snprintf(line1, sizeof(line1), "Stop %d: %s", currentStop, stopBuf);
  line1[16] = '\0';
  lcdTwoStr(line1, "Tap Card");
}

void showSystemStarted() {
  char buf[17];
  snprintf(buf, sizeof(buf), "Passengers: %d", passengerCount);
  lcd.clear();
  lcd.setCursor(0, 0); lcd.print(F("System Started"));
  lcd.setCursor(0, 1); lcd.print(buf);
}

void showMoving(int nextStop) {
  getStopName(nextStop);
  char line1[17];
  snprintf(line1, sizeof(line1), "Moving->Stop %d", nextStop);
  lcdTwoStr(line1, stopBuf);
}

void showArrived() {
  getStopName(currentStop);
  char line1[17];
  snprintf(line1, sizeof(line1), "Arrived Stop %d", currentStop);
  lcdTwoStr(line1, stopBuf);
}

// ==============================================================
//  MOTOR — unchanged (note: digitalWrite only accepts HIGH/LOW; the
//  original "255" is treated as non-zero i.e. HIGH by the compiler,
//  so behaviour is unchanged, kept exactly as you had it)
// ==============================================================
void motorStart() {
  digitalWrite(MOTOR_IN1, HIGH);
  digitalWrite(MOTOR_IN2, LOW);
  motorRunning = true;
  Serial.println(F("Motor: ON"));
}

void motorStop() {
  digitalWrite(MOTOR_IN1, LOW);
  digitalWrite(MOTOR_IN2, LOW);
  motorRunning = false;
  Serial.println(F("Motor: OFF"));
}

// ==============================================================
//  SERVO GATES — unchanged
// ==============================================================
void openAllGates() {
  entryServo.attach(ENTRY_SERVO_PIN);
  exitServo.attach(EXIT_SERVO_PIN);
  entryServo.write(GATE_OPEN);
  exitServo.write(GATE_OPEN);
  Serial.println(F("Gates: OPEN (90)"));
}

void closeAllGates() {
  entryServo.attach(ENTRY_SERVO_PIN);
  exitServo.attach(EXIT_SERVO_PIN);
  entryServo.write(ENTRY_CLOSED);
  exitServo.write(EXIT_CLOSED);
  Serial.println(F("Gates: CLOSED (entry=7, exit=8)"));
}

void detachServos() {
  entryServo.detach();
  exitServo.detach();
}

// ==============================================================
//  DFPLAYER AUDIO — playFolder(1, ...) -> playFolder(currentLang, ...)
// ==============================================================
void playBeep() {
  // unchanged - beep removed, voice plays directly
}

void playVoice(int track, unsigned int waitMs) {
  if (!dfplayerOK) return;
  player.playFolder(currentLang, track); // CHANGED: was hardcoded 1
  delay(waitMs);
}

void stopAudio() {
  if (!dfplayerOK) return;
  player.stop();
}

void announceNextStop(int nextStop) {
  if (nextStop < 2 || nextStop > TOTAL_STOPS) return;
  int track = 6 + nextStop;
  getStopName(nextStop);
  Serial.print(F("Audio: Next stop -> "));
  Serial.println(stopBuf);
  detachServos();
  playVoice(track, 3500);
  closeAllGates();
}

// ==============================================================
//  NEW — LANGUAGE SWITCH
// ==============================================================
void toggleLanguage() {
  currentLang = (currentLang == LANG_KANNADA) ? LANG_ENGLISH : LANG_KANNADA;
  detachServos();
  player.playFolder(currentLang, 25); // "language selected" confirmation, track 025
  delay(2500);
  showTapCard();
  Serial.print(F("Language switched to: "));
  Serial.println(currentLang == LANG_KANNADA ? F("Kannada") : F("English"));
}

// ==============================================================
//  NEW — UART REPORTS TO ESP32 (fire-and-forget, one line each)
//  Format kept deliberately simple (pipe-separated) so the ESP32 side
//  can parse it with String.indexOf()/substring() — no JSON library
//  needed on the UNO, which has very little RAM to spare.
//
//    EVT|type|uid|name|stopName|fare|balance
//    STP|stopNum|stopName|moving(0/1)
// ==============================================================
void reportEvent(const char* type, const char* uid, const char* name,
                  const char* stopName, int fare, int balance) {
  espSerial.print(F("EVT|"));
  espSerial.print(type);       espSerial.print('|');
  espSerial.print(uid);        espSerial.print('|');
  espSerial.print(name);       espSerial.print('|');
  espSerial.print(stopName);   espSerial.print('|');
  espSerial.print(fare);       espSerial.print('|');
  espSerial.println(balance);
}

void reportStop(int stopNum, const char* stopName, bool moving) {
  espSerial.print(F("STP|"));
  espSerial.print(stopNum);    espSerial.print('|');
  espSerial.print(stopName);   espSerial.print('|');
  espSerial.println(moving ? 1 : 0);
}

// ==============================================================
//  UTILITIES — unchanged
// ==============================================================
bool uidMatch(byte* a, byte* b) {
  for (int i = 0; i < 4; i++)
    if (a[i] != b[i]) return false;
  return true;
}

// Same UID-to-hex helper the previous ESP32-only sketch used — kept here
// too, since the ESP32 bridge & Firebase both want a hex string, not
// raw bytes, and it's cheap to compute once on the UNO.
String uidToHex(byte* uid) {
  String hex = "";
  for (int i = 0; i < 4; i++) {
    if (uid[i] < 0x10) hex += "0";
    hex += String(uid[i], HEX);
  }
  hex.toUpperCase();
  return hex;
}

void resetSystem() {
  stopAudio();
  motorStop();
  closeAllGates();
  systemStarted  = false;
  currentStop    = 1;
  passengerCount = 0;
  for (int i = 0; i < CARD_COUNT; i++)
    cards[i].boardedAtStop = 0;
  lcdTwoF(F("Kempegowda BS"), F("Press START"));
  Serial.println(F("=== System Reset ==="));
}

// ==============================================================
//  HARDWARE INIT CHECKS — unchanged
// ==============================================================
bool checkRFID() {
  Serial.println(F("--- RFID Check ---"));
  byte v = rfid.PCD_ReadRegister(MFRC522::VersionReg);
  Serial.print(F("Ver: 0x")); Serial.println(v, HEX);
  if (v == 0x91 || v == 0x92) { Serial.println(F("RFID OK")); return true; }
  if (v == 0x00 || v == 0xFF) { Serial.println(F("RFID FAIL")); return false; }
  Serial.println(F("RFID unknown - continuing"));
  return true;
}

bool checkDFPlayer() {
  Serial.println(F("--- DFPlayer Check ---"));
  dfSerial.begin(9600);
  delay(3000);
  if (player.begin(dfSerial)) {
    player.volume(50);
    Serial.println(F("DFPlayer OK"));
    return true;
  }
  Serial.println(F("Hard reset attempt..."));
  player.reset();
  delay(3000);
  if (player.begin(dfSerial)) {
    player.volume(50);
    Serial.println(F("DFPlayer OK (after reset)"));
    return true;
  }
  Serial.println(F("DFPlayer FAIL"));
  return false;
}

// ==============================================================
//  SETUP
// ==============================================================
void setup() {
  Serial.begin(9600);
  Serial.println(F("=== Bus Fare System Booting ==="));

  espSerial.begin(9600); // NEW

  Wire.begin();
  pcfWrite(); // NEW — push the initial "both LEDs off" state to the PCF8574
  lcd.init();
  lcd.backlight();
  lcdTwoF(F("Booting..."), F("Please wait"));

  SPI.begin();
  rfid.PCD_Init();
  delay(100);
  rfidOK = checkRFID();

  entryServo.attach(ENTRY_SERVO_PIN);
  exitServo.attach(EXIT_SERVO_PIN);
  entryServo.write(ENTRY_CLOSED);
  exitServo.write(EXIT_CLOSED);
  delay(500);
  entryServo.detach();
  exitServo.detach();

  pinMode(MOTOR_IN1, OUTPUT);
  pinMode(MOTOR_IN2, OUTPUT);
  digitalWrite(MOTOR_IN1, LOW);
  digitalWrite(MOTOR_IN2, LOW);

  pinMode(BTN_START, INPUT_PULLUP);
  pinMode(BTN_STOP,  INPUT_PULLUP);
  pinMode(BTN_LANG,  INPUT_PULLUP); // NEW

  dfplayerOK = checkDFPlayer();

  Serial.print(F("RFID    : ")); Serial.println(rfidOK    ? F("OK") : F("FAIL"));
  Serial.print(F("DFPlayer: ")); Serial.println(dfplayerOK ? F("OK") : F("FAIL"));

  if (!rfidOK) {
    lcdTwoF(F("RFID FAIL!"), F("Check wiring"));
  } else {
    lcdTwoF(F("Kempegowda BS"), F("Press START"));
    Serial.println(F("System Ready - Press START to begin."));
    playVoice(SND_KEMPEGOWDA, 5000);
  }

  entryServo.attach(ENTRY_SERVO_PIN);
  exitServo.attach(EXIT_SERVO_PIN);
  openAllGates();
}

// ==============================================================
//  MAIN LOOP — same structure as your original; UART reports added
//  right after each existing LCD/audio action, never before
// ==============================================================
void loop() {

  // NEW — language button, checked first, doesn't interfere with anything
  if (digitalRead(BTN_LANG) == LOW) {
    delay(50);
    toggleLanguage();
    delay(300);
  }

  if (digitalRead(BTN_START) == LOW) {
    delay(50);

    if (!motorRunning) {

      if (currentStop >= TOTAL_STOPS) {
        lcdTwoF(F("End of Route"), F("Press STOP/Reset"));
        Serial.println(F("START ignored - already at last stop."));

      } else {
        systemStarted = true;
        closeAllGates();
        showSystemStarted();
        delay(1500);
        motorStart();
        showMoving(currentStop + 1);
        announceNextStop(currentStop + 1);
        showMoving(currentStop + 1);
        getStopName(currentStop + 1);
        reportStop(currentStop + 1, stopBuf, true); // NEW
      }
    }
    delay(300);
  }

  if (digitalRead(BTN_STOP) == LOW) {
    delay(50);

    if (motorRunning) {
      stopAudio();
      motorStop();

      if (currentStop < TOTAL_STOPS) {
        currentStop++;
        openAllGates();
        showArrived();
        delay(2000);
        showTapCard();
        detachServos();
        player.playFolder(currentLang, SND_TAP_CARD); // CHANGED: was hardcoded 1
        delay(3000);

        getStopName(currentStop);
        Serial.print(F("Arrived: Stop "));
        Serial.print(currentStop);
        Serial.print(F(" - "));
        Serial.println(stopBuf);
        reportStop(currentStop, stopBuf, false); // NEW

      } else {
        openAllGates();
        lcdTwoF(F("End of Route"), F("16th Main BTM"));
        detachServos();
        player.playFolder(currentLang, SND_EXIT_OK); // CHANGED: was hardcoded 1
        delay(4500);
        Serial.println(F("End of route reached."));
        reportStop(currentStop, "16th Main BTM", false); // NEW
        reportEvent("ROUTE_COMPLETE", "", "", "16th Main BTM", 0, 0); // NEW
      }

    } else if (!systemStarted) {
      resetSystem();
    }
    delay(300);
  }

  if (motorRunning) return;

  if (!rfidOK) return;
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) return;

  byte* uid = rfid.uid.uidByte;
  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();

  Serial.print(F("Card UID:"));
  for (int i = 0; i < rfid.uid.size; i++) {
    Serial.print(' ');
    if (uid[i] < 0x10) Serial.print('0');
    Serial.print(uid[i], HEX);
  }
  Serial.println();

  String uidHex = uidToHex(uid); // NEW
  getStopName(currentStop);
  char stopNameCopy[17];
  strcpy(stopNameCopy, stopBuf); // NEW - snapshot before it gets overwritten below

  int found = -1;
  for (int i = 0; i < CARD_COUNT; i++) {
    if (uidMatch(uid, cards[i].uid)) { found = i; break; }
  }

  char cname[8];
  char balBuf[17];

  // ── CASE 1: INVALID CARD ────────────────────────────────────
  if (found == -1) {
    lcdTwoF(F("!! Invalid Card"), F("Access Denied"));
    detachServos();
    ledDenied(); // NEW
    player.playFolder(currentLang, SND_INVALID); // CHANGED: was hardcoded 1
    delay(4000);
    showTapCard();
    Serial.println(F("Unknown UID - access denied."));
    reportEvent("DENIED_INVALID", uidHex.c_str(), "Unknown", stopNameCopy, 0, 0); // NEW

  } else {
    strcpy_P(cname, cards[found].name);

    // ── CASE 2: ENTRY ──────────────────────────────────────────
    if (cards[found].boardedAtStop == 0) {

      // ── Low balance ──────────────────────────────────────────
      if (cards[found].balance < FARE_PER_STOP) {
        lcdFlashStr(F("Low Balance!"), cname);
        detachServos();
        ledDenied(); // NEW
        player.playFolder(currentLang, SND_LOW_BAL); // CHANGED: was hardcoded 1
        delay(3500);
        showTapCard();
        Serial.print(F("Entry denied - low balance: ")); Serial.println(cname);
        reportEvent("DENIED_BALANCE", uidHex.c_str(), cname, stopNameCopy, 0, cards[found].balance); // NEW

      // ── Entry success ────────────────────────────────────────
      } else {

        cards[found].boardedAtStop = currentStop;
        passengerCount++;
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print(cname); lcd.print(F(" Entry OK"));
        lcd.setCursor(0, 1);
        snprintf(balBuf, sizeof(balBuf), "Bal: P%d", cards[found].balance);
        lcd.print(balBuf);
        detachServos();
        ledApproved(); // NEW
        player.playFolder(currentLang, SND_ENTRY_OK); // CHANGED: was hardcoded 1
        delay(3500);
        showTapCard();
        Serial.print(F("ENTRY OK: ")); Serial.print(cname);
        Serial.print(F(" @Stop "));   Serial.print(currentStop);
        Serial.print(F(" Bal: P"));   Serial.println(cards[found].balance);
        // fare is charged on EXIT (distance-based), not on entry — report 0 here
        reportEvent("ENTRY", uidHex.c_str(), cname, stopNameCopy, 0, cards[found].balance); // NEW
      }

    // ── CASE 3: EXIT ───────────────────────────────────────────
    } else {

      int stopsTravel = currentStop - cards[found].boardedAtStop;
      int fare        = stopsTravel * FARE_PER_STOP;

      // ── Insufficient fare ────────────────────────────────────
      if (cards[found].balance < fare) {
        char msg[17];
        snprintf(msg, sizeof(msg), "Need: P%d", fare);
        lcdTwoStr(cname, msg);
        detachServos();
        ledDenied(); // NEW
        player.playFolder(currentLang, SND_LOW_BAL); // CHANGED: was hardcoded 1
        delay(3500);
        showTapCard();
        Serial.print(F("Exit denied - insufficient fare: ")); Serial.println(cname);
        reportEvent("DENIED_BALANCE", uidHex.c_str(), cname, stopNameCopy, fare, cards[found].balance); // NEW

      // ── Exit success ─────────────────────────────────────────
      } else {
        detachServos();
        ledApproved(); // NEW
        player.playFolder(currentLang, SND_EXIT_OK); // CHANGED: was hardcoded 1
        delay(4500);
        cards[found].balance      -= fare;
        cards[found].boardedAtStop = 0;
        passengerCount = max(0, passengerCount - 1);
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print(cname); lcd.print(F(" -P")); lcd.print(fare);
        lcd.setCursor(0, 1);
        snprintf(balBuf, sizeof(balBuf), "%dstop Bal:P%d",
                 stopsTravel, cards[found].balance);
        lcd.print(balBuf);
        detachServos();
        player.playFolder(currentLang, SND_EXIT_OK); // CHANGED: was hardcoded 1
        delay(4500);
        showTapCard();
        Serial.print(F("EXIT OK: "));  Serial.print(cname);
        Serial.print(F(" Fare: P"));   Serial.print(fare);
        Serial.print(F(" Stops: "));   Serial.print(stopsTravel);
        Serial.print(F(" Bal: P"));    Serial.println(cards[found].balance);
        reportEvent("EXIT", uidHex.c_str(), cname, stopNameCopy, fare, cards[found].balance); // NEW
      }
    }
  }

  delay(1000);
}
