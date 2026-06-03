// ============================================================
//  Automatic Bus Fare Collection System  –  FINAL VERSION
//  Board   : Arduino UNO
//  Hardware: MFRC522 RFID · DFPlayer Mini · 16x2 I2C LCD
//            · 2x Servo (Entry A2 / Exit A3)
//            · L293D DC Motor (IN1→5, IN2→6)
//            · START button A0 · STOP button A1
// ============================================================
//
//  SD CARD LAYOUT  /01/
//  002.mp3  = "Please tap your card"
//  003.mp3  = "Entry successful"
//  004.mp3  = "Exit successful, thank you for travelling with us"
//  005.mp3  = "Invalid card, please try again"
//  006.mp3  = "Insufficient balance"
//  007.mp3  = "Bus currently at Kempegowda. Starting shortly."
//  008.mp3  = Maharani College     (stop 2)   ← track = 6 + stopNum
//  009.mp3  = KR Circle            (stop 3)
//  ...
//  024.mp3  = 16th Main BTM        (stop 18)
//
//  SERVO ANGLES
//  CLOSED  : Entry = 7°,  Exit = 8°
//  OPEN    : Both  = 90°
//
//  AUDIO RULES (no overlap / no interference)
//  ─ Card scanned (any result)       → Beep FIRST, then voice
//  ─ Invalid card (UID not in list)  → Beep + "Invalid card" ONLY
//  ─ Insufficient balance            → Beep + "Insufficient balance" ONLY
//  ─ Entry success                   → Beep + "Entry successful"
//  ─ Exit success                    → Beep + "Exit successful…"
//  ─ START pressed                   → Next-stop name announced (track 6+N)
//  ─ STOP pressed                    → "Please tap your card"
//
//  SCREEN HOLD TIMES
//  ─ Error / success messages        → 3500 ms before returning to tap screen
// ============================================================

#include <SPI.h>
#include <MFRC522.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Servo.h>
#include <SoftwareSerial.h>
#include <DFRobotDFPlayerMini.h>

// ─── Pin Definitions ───────────────────────────────────────────
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

// ─── Servo Angles ──────────────────────────────────────────────
#define ENTRY_CLOSED     7
#define EXIT_CLOSED      8
#define GATE_OPEN       90

// ─── Audio Track Numbers ───────────────────────────────────────
#define SND_BEEP         1
#define SND_TAP_CARD     2
#define SND_ENTRY_OK     3
#define SND_EXIT_OK      4
#define SND_INVALID      5
#define SND_LOW_BAL      6
#define SND_KEMPEGOWDA   7
// Stop-name track formula: track = 6 + stopNum
// stop 2 → track 8, stop 18 → track 24

// ─── Stop Names (PROGMEM) ──────────────────────────────────────
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

// ─── Card Database ─────────────────────────────────────────────
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

// ─── Global State ──────────────────────────────────────────────
bool systemStarted  = false;
bool motorRunning   = false;
int  currentStop    = 1;
bool rfidOK         = false;
bool dfplayerOK     = false;
int  passengerCount = 0;

// ==============================================================
//  LCD HELPERS
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
//  MOTOR
// ==============================================================
void motorStart() {
  digitalWrite(MOTOR_IN1, 255);
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
//  SERVO GATES
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
//  DFPLAYER AUDIO
//  ── CHANGE: playFolder(1, track) used for both beep and voice
// ==============================================================
void playBeep() {
  // do nothing - beep removed, voice plays directly
}

void playVoice(int track, unsigned int waitMs) {
  if (!dfplayerOK) return;
  player.playFolder(1, track);
  delay(waitMs);
}

void stopAudio() {
  if (!dfplayerOK) return;
  player.stop();
}

void announceNextStop(int nextStop) {
  if (nextStop < 2 || nextStop > TOTAL_STOPS) return;
  int track = 6 + nextStop;  // stop 2 → track 8, stop 18 → track 24
  getStopName(nextStop);
  Serial.print(F("Audio: Next stop → "));
  Serial.println(stopBuf);
  detachServos();
  playVoice(track, 3500);
  closeAllGates();
}

// ==============================================================
//  UTILITIES
// ==============================================================
bool uidMatch(byte* a, byte* b) {
  for (int i = 0; i < 4; i++)
    if (a[i] != b[i]) return false;
  return true;
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
//  HARDWARE INIT CHECKS
// ==============================================================
bool checkRFID() {
  Serial.println(F("--- RFID Check ---"));
  byte v = rfid.PCD_ReadRegister(MFRC522::VersionReg);
  Serial.print(F("Ver: 0x")); Serial.println(v, HEX);
  if (v == 0x91 || v == 0x92) { Serial.println(F("RFID OK")); return true; }
  if (v == 0x00 || v == 0xFF) { Serial.println(F("RFID FAIL")); return false; }
  Serial.println(F("RFID unknown – continuing"));
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
  Serial.println(F("Hard reset attempt…"));
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

  Wire.begin();
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

  dfplayerOK = checkDFPlayer();

  Serial.print(F("RFID    : ")); Serial.println(rfidOK    ? F("OK") : F("FAIL"));
  Serial.print(F("DFPlayer: ")); Serial.println(dfplayerOK ? F("OK") : F("FAIL"));

  if (!rfidOK) {
    lcdTwoF(F("RFID FAIL!"), F("Check wiring"));
  } else {
    lcdTwoF(F("Kempegowda BS"), F("Press START"));
    Serial.println(F("System Ready – Press START to begin."));
    playVoice(SND_KEMPEGOWDA, 5000);  // 007 boot announcement
  }

  entryServo.attach(ENTRY_SERVO_PIN);
  exitServo.attach(EXIT_SERVO_PIN);
  openAllGates();
}

// ==============================================================
//  MAIN LOOP
// ==============================================================
void loop() {

  if (digitalRead(BTN_START) == LOW) {
    delay(50);

    if (!motorRunning) {

      if (currentStop >= TOTAL_STOPS) {
        lcdTwoF(F("End of Route"), F("Press STOP/Reset"));
        Serial.println(F("START ignored – already at last stop."));

      } else {
        systemStarted = true;
        closeAllGates();
        showSystemStarted();
        delay(1500);
        motorStart();
        showMoving(currentStop + 1);
        announceNextStop(currentStop + 1);
        showMoving(currentStop + 1);
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
        player.playFolder(1, SND_TAP_CARD);
        delay(3000);

        Serial.print(F("Arrived: Stop "));
        Serial.print(currentStop);
        Serial.print(F(" – "));
        getStopName(currentStop);
        Serial.println(stopBuf);

      } else {
        openAllGates();
        lcdTwoF(F("End of Route"), F("16th Main BTM"));
        detachServos();
        player.playFolder(1, SND_EXIT_OK);
        delay(4500);
        Serial.println(F("End of route reached."));
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
    player.playFolder(1, SND_INVALID);  // direct call, no beep first
    delay(4000);
    showTapCard();
    Serial.println(F("Unknown UID – access denied."));

  } else {
    strcpy_P(cname, cards[found].name);

    // ── CASE 2: ENTRY ──────────────────────────────────────────
    if (cards[found].boardedAtStop == 0) {

      // ── Low balance ──────────────────────────────────────────
      if (cards[found].balance < FARE_PER_STOP) {
        lcdFlashStr(F("Low Balance!"), cname);
        detachServos();
        player.playFolder(1, SND_LOW_BAL);
        delay(3500);
        showTapCard();
        Serial.print(F("Entry denied – low balance: ")); Serial.println(cname);

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
        player.playFolder(1, SND_ENTRY_OK);
        delay(3500);
        showTapCard();
        Serial.print(F("ENTRY OK: ")); Serial.print(cname);
        Serial.print(F(" @Stop "));   Serial.print(currentStop);
        Serial.print(F(" Bal: P"));   Serial.println(cards[found].balance);
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
        player.playFolder(1, SND_LOW_BAL);
        delay(3500);
        showTapCard();
        Serial.print(F("Exit denied – insufficient fare: ")); Serial.println(cname);

      // ── Exit success ─────────────────────────────────────────
      } else {
       detachServos();
        player.playFolder(1, SND_EXIT_OK);
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
        player.playFolder(1, SND_EXIT_OK);
        delay(4500);
        showTapCard();
        Serial.print(F("EXIT OK: "));  Serial.print(cname);
        Serial.print(F(" Fare: P"));   Serial.print(fare);
        Serial.print(F(" Stops: "));   Serial.print(stopsTravel);
        Serial.print(F(" Bal: P"));    Serial.println(cards[found].balance);
      }
    }
  }

  delay(1000);
}
