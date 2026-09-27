# Smart Bus — UNO + ESP32 + Firebase Hardware Integration Guide

## What changed, in one paragraph

Your Arduino UNO keeps doing exactly what it already does — reading
RFID, deciding Entry/Exit/Deny using its own card database, controlling
the gates/motor/LCD/audio — completely unchanged in logic. Two things
were added: (1) it now also speaks Kannada or English depending on a new
language button, and (2) after every decision it sends one short line
out over a UART wire to a **separate ESP32 board**, which forwards that
line to your phone app and to Firebase. If the ESP32, WiFi, or Firebase
are all dead, the UNO doesn't notice or care — it keeps working exactly
as it did standalone.

---

## 1. Circuit review — from your photo

I can clearly identify every component you listed is present: the LCD,
RFID-RC522, a motor driver board, two small dev boards, two servos, a
DC motor, a speaker, and two push buttons. **What I can't do reliably**
is trace exact pin numbers through that many overlapping wires in a
photo — getting that wrong on safety-critical lines (RFID power, ESP32
logic levels) would be worse than not guessing at all. So instead, here
is the definitive checklist to verify by hand against your actual wires.
This is more reliable than a photo trace, and it's what actually matters.

### ✅ Confirm these before powering anything on

| # | Check | Why it matters |
|---|---|---|
| 1 | **RFID-RC522 VCC → 3.3V, not 5V** | The RC522 module is 3.3V-only. Powering it from 5V can permanently damage it. Its SPI data lines (RST, MOSI, MISO, SCK, SDA/SS) can safely connect straight to the UNO's 5V-logic pins — only the **power pin** must be 3.3V. |
| 2 | **UNO's 5V rail powers**: LCD, servos, motor driver logic side, buttons | These are all fine on 5V. |
| 3 | **ESP32 VCC → its own 3.3V/5V input pin (check your specific board), never wired to UNO's 5V logic-out pins directly** | Follow your ESP32 board's own power spec — most dev boards accept 5V on the `VIN`/`5V` pin (has an onboard regulator) but GPIOs are strictly 3.3V. |
| 4 | **UNO TX (pin A2 in the new wiring) → ESP32 RX2 (pin 16) goes THROUGH A VOLTAGE DIVIDER, not a direct wire** | This is the #1 way to damage an ESP32 in these projects. UNO outputs 5V logic; ESP32 inputs tolerate 3.3V max. See section 2 for the exact divider. |
| 5 | **ESP32 TX2 (pin 17) → UNO RX (pin 4) can be a direct wire** | 3.3V is high enough for the UNO to reliably read as HIGH — no divider strictly required in this direction, though a level shifter module improves reliability if you have one spare. |
| 6 | **Common ground between UNO and ESP32** | Both boards' GND pins must be wired together, in addition to the RX/TX lines. Without a shared ground, serial communication will be unreliable or fail completely. |
| 7 | **Motor driver board has power jumper/ENA tied HIGH** | Your code drives `MOTOR_IN1`/`MOTOR_IN2` directly with no separate speed-enable pin. Most small L293D breakout boards have a jumper that ties the enable pin HIGH permanently — confirm yours does, or the motor simply won't turn no matter what the code does. |
| 8 | **Servo signal wires → digital pins 7 (entry) and 8 (exit)**, servo **red wire → 5V**, servo **black/brown wire → GND** | Reversing signal and power on a 3-wire servo connector is a common miswiring that either does nothing or damages the servo. |
| 9 | **DFPlayer Mini has its SD card inserted and formatted correctly** | See the separate `DFPLAYER_TWO_LANGUAGE_GUIDE.md` for exact folder/file requirements. |

### Wiring table — the definitive pin map (matches the code exactly)

| Component | Pin | UNO pin |
|---|---|---|
| RFID SS/SDA | SS | 10 |
| RFID RST | RST | 9 |
| RFID SCK/MOSI/MISO | fixed hardware SPI | 13 / 11 / 12 (do not reuse these for anything else) |
| Motor driver IN1 | IN1 | 5 |
| Motor driver IN2 | IN2 | 6 |
| Entry servo signal | signal | 7 |
| Exit servo signal | signal | 8 |
| START button | one leg | A0 (other leg to GND) |
| STOP button | one leg | A1 (other leg to GND) |
| **LANGUAGE button (NEW)** | one leg | **A3** (other leg to GND) |
| DFPlayer RX | RX | 3 |
| DFPlayer TX | TX | 2 |
| **ESP32 link RX (NEW)** | UNO receives | **pin 4** (wire from ESP32 TX2/pin 17) |
| **ESP32 link TX (NEW)** | UNO transmits | **pin A2** (wire to ESP32 RX2/pin 16, THROUGH DIVIDER) |
| LCD SDA / SCL | I2C | A4 / A5 |

---

## 2. The voltage divider (UNO TX → ESP32 RX2)

Simplest, cheapest fix — two resistors:

```
UNO pin A2 (5V logic) ---[1kΩ]---+---[2kΩ]--- GND
                                  |
                                  +--- ESP32 pin 16 (RX2)
```

This drops the 5V signal down to roughly 3.3V before it reaches the
ESP32. Any resistor pair with roughly a 1:2 ratio works (1kΩ+2kΩ,
10kΩ+20kΩ, etc.) — exact values aren't critical, the ratio is what
matters. If you have a proper bidirectional logic-level shifter module,
that also works and is slightly more robust — use it on both lines if
you have one.

---

## 3. Arduino UNO setup

1. **Arduino IDE → Tools → Board** → "Arduino Uno"
2. **Tools → Port** → select the COM port your UNO shows up on
3. **Install libraries** (Tools → Manage Libraries, search each):
   - `MFRC522` by GithubCommunity
   - `LiquidCrystal I2C` by Frank de Brabander (or Marco Schwartz — either common fork works)
   - `Servo` (usually pre-installed with Arduino IDE)
   - `DFRobotDFPlayerMini` by DFRobot
   - `SoftwareSerial` (built into Arduino IDE, no install needed)
4. Open `arduino_uno_final.ino`
5. Click **Upload**
6. Open **Serial Monitor**, set baud rate to **9600** — you should see the boot sequence (`RFID OK`, `DFPlayer OK`, etc.)

---

## 4. ESP32 setup

1. If you haven't already, install ESP32 board support: **File → Preferences** → paste this into "Additional Board Manager URLs":
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
   Then **Tools → Board → Boards Manager** → search "esp32" → install
2. **Tools → Board** → select your specific ESP32 board (e.g. "ESP32 Dev Module")
3. **Tools → Port** → select the ESP32's COM port
4. **Install libraries**:
   - `Firebase ESP Client` by Mobizt
   - `ArduinoJson` by Benoit Blanchon (v6.x)
5. Open `esp32_firebase_bridge.ino`
6. Edit the top of the file:
   ```cpp
   const char* WIFI_SSID     = "...";
   const char* WIFI_PASSWORD = "...";
   String PHONE_IP    = "192.168.1.100"; // from the app's Telemetry panel
   #define FIREBASE_HOST   "..."
   #define FIREBASE_AUTH   "..."
   #define API_KEY         "..."
   ```
   (see section 5 for exactly where each Firebase value comes from)
7. Click **Upload**
8. Open **Serial Monitor** at **115200** baud — you should see `WiFi connected` and `Firebase initialized.`

---

## 5. Firebase Realtime Database setup

This is a **different Firebase product** from the Cloud Firestore your
Android app already uses for login — RTDB is a separate service inside
the same Firebase project, used here purely as a live event mirror.

1. Go to your existing Firebase project at console.firebase.google.com
   (the same one your Android app already uses for Authentication)
2. Left sidebar → **Build → Realtime Database**
3. Click **Create Database**
4. Choose a location close to you → **Start in test mode** (fine for a
   student project — same reasoning as the Firestore test mode setup)
5. Once created, copy the URL shown at the top (looks like
   `https://your-project-id-default-rtdb.firebaseio.com/`) → this is
   your `FIREBASE_HOST` (paste it **without** `https://` and **without**
   the trailing slash)
6. Get your Database Secret: click the **⚙️ gear icon** (top-left, next
   to "Project Overview") → **Project settings** → **Service accounts**
   tab → **Database secrets** → click **Show** next to the secret →
   copy it → this is your `FIREBASE_AUTH`
7. Get your Web API Key: same **Project settings** page → **General**
   tab → scroll to "Your apps" → find the **Web API Key** field → copy
   it → this is your `API_KEY`

### Example database structure once it's running

```json
{
  "smart_bus": {
    "status": {
      "stopNum": 4,
      "stopName": "St Marthas Hosp",
      "moving": true,
      "lastUpdated": 1735000000000
    },
    "events": {
      "-Nabc123...": {
        "type": "ENTRY",
        "uid": "5B850B1A",
        "name": "Card 1",
        "stop": "Kempegowda BS",
        "fare": 0,
        "balance": 200,
        "timestamp": 1735000000000
      },
      "-Nabc124...": {
        "type": "EXIT",
        "uid": "5B850B1A",
        "name": "Card 1",
        "stop": "St Marthas Hosp",
        "fare": 30,
        "balance": 170,
        "timestamp": 1735000050000
      }
    }
  }
}
```

### Database rules (test mode default — fine for a student project)
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```
Same security caveat as before: open rules are fine for a demo/viva,
not for a public production release.

---

## 6. Android application — do you need to change anything?

**No required changes.** The routes your ESP32 posts to
(`/api/bus/event` and `/api/bus/stop`) already exist in the app's
embedded server and are already wired to update the dashboard's live
feed and current-stop display. This was built in an earlier session
specifically for a self-contained hardware board reporting its own
decisions — which is exactly what's happening here, just relayed
through a UART link instead of the ESP32 doing the RFID reading itself.

**Optional enhancement, not required:** if you also want the app to
read live data from Firebase RTDB (so it updates even when the phone
isn't on the same WiFi as the bus), that's a separate, additive feature
I can build if you want it — say the word and I'll add a
`firebase_database` listener alongside the existing local server, not
replacing it.

---

## 7. Power-up order (do this every time, matters for reliability)

1. Power the **UNO** first (via USB or its own supply) — let it finish
   its boot sequence (RFID/DFPlayer checks, "Press START" on the LCD)
2. Power the **ESP32** — let it connect to WiFi (watch its Serial
   Monitor for "WiFi connected")
3. Open the **Flutter app** on the phone, make sure the Telemetry panel
   shows the server as running
4. Only then start tapping cards / pressing START

Powering everything on simultaneously usually still works, but doing it
in this order avoids a specific class of intermittent bug where the
ESP32 tries to send data before its WiFi/Firebase connection is ready.

---

## 8. Testing checklist

Work through these in order — each builds on the previous one working:

- [ ] UNO Serial Monitor shows `RFID OK` and `DFPlayer OK` on boot
- [ ] LCD shows "Kempegowda BS / Press START"
- [ ] Tap a known card UID → LCD shows "Entry OK", correct audio plays
- [ ] Press LANGUAGE button → hear the language-confirmation track,
      then tap a card again → announcements now play in the other language
- [ ] Press START → motor runs, LCD shows "Moving->Stop 2", next-stop
      audio plays
- [ ] Press STOP → motor stops, gates open, LCD shows "Arrived Stop 2"
- [ ] Tap the same card again → LCD shows "Exit OK" with fare deducted
- [ ] Tap an unregistered card → "Invalid Card" plays, gate stays shut
- [ ] Drain a test card's balance below fare → "Low Balance" plays,
      access denied
- [ ] ESP32 Serial Monitor shows `WiFi connected` and `Firebase initialized.`
- [ ] ESP32 Serial Monitor shows `UNO -> EVT|...` lines appearing each
      time you tap a card on the UNO
- [ ] Phone app's **Telemetry Source** panel shows the ESP32 as connected
- [ ] Phone app's **live transaction feed** shows a new row appear
      within a second or two of each tap
- [ ] Firebase console → Realtime Database → Data tab shows new entries
      appearing under `smart_bus/events` as you tap cards
- [ ] Complete a full route (START repeatedly to the last stop) →
      "End of Route" plays, Firebase shows a `ROUTE_COMPLETE` event

---

## 9. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| ESP32 won't connect to WiFi | Wrong SSID/password, or 5GHz-only network | ESP32 only supports 2.4GHz WiFi — check your router band; double-check credentials for typos |
| ESP32 connects to WiFi but Firebase never initializes | Wrong `FIREBASE_HOST`/`FIREBASE_AUTH`/`API_KEY` | Re-copy each value carefully from section 5 — a single wrong character breaks it silently |
| ESP32 Serial Monitor shows nothing from the UNO (`UNO -> ...` never appears) | UART wiring wrong, or missing common ground | Re-check section 2's divider wiring and confirm both boards' GND pins are joined |
| UNO seems to freeze/reset when a card is tapped | Voltage divider missing on UNO TX → ESP32 RX2, causing a brownout/short | Add the divider — do not wire that line directly |
| DFPlayer plays nothing | SD card not formatted FAT32, or file naming wrong | See `DFPLAYER_TWO_LANGUAGE_GUIDE.md`, sections 1–2 |
| RFID never detects cards | RC522 powered from 5V instead of 3.3V (may have damaged the module — try a replacement), or SPI wiring wrong | Re-check checklist item 1; if the module was run on 5V even briefly, consider replacing it, as damage isn't always immediately total |
| LCD shows nothing / garbled characters | Wrong I2C address (some boards use `0x3F` instead of `0x27`) or SDA/SCL swapped | Run an I2C scanner sketch to confirm the address; edit `lcd(0x27, 16, 2)` in the code if needed |
| Servo twitches but doesn't hold position | Servo power drawing too much current from the UNO's 5V pin directly | Power servos from a separate 5V supply with shared ground, not straight off the UNO's onboard regulator, especially with 2 servos + a motor all on one board |
| Android app never shows hardware events | Phone and ESP32 not on the same WiFi network, or wrong `PHONE_IP` | Re-check the IP shown in the app's Telemetry panel matches `PHONE_IP` in the ESP32 sketch exactly; re-check for router client isolation (see main SETUP_GUIDE.md's troubleshooting section) |
| Wrong language plays | SD card folders swapped (01 should be Kannada, 02 English) | Re-check folder contents against `DFPLAYER_TWO_LANGUAGE_GUIDE.md` |
| Firebase shows events but app doesn't | Expected — RTDB and the local HTTP route are two independent paths (see section 6); this isn't a bug unless you've asked for the optional RTDB-in-app listener | No fix needed unless you want that optional feature |

---

## 10. Summary of every modification made

| File | What changed |
|---|---|
| `arduino_uno_final.ino` | Added UART reporting (3 new functions, called at the same points your original code already made decisions), added bilingual language button + `currentLang` variable, replaced every hardcoded `playFolder(1, ...)` with `playFolder(currentLang, ...)`. Everything else — card database, fare math, servo angles, LCD text, button debounce timing — byte-for-byte unchanged. |
| `esp32_firebase_bridge.ino` | New file. Pure relay: reads UART lines from the UNO, forwards to the phone app's existing routes and to Firebase RTDB. Makes no fare decisions. |
| `DEPRECATED_esp32_only_variant.ino` | Superseded — this was an earlier single-board design where the ESP32 itself did the RFID reading. Your actual hardware uses two separate boards, so this file is kept for reference only. |
| Android app | No changes required — already built and already wired to receive exactly this data. |
| Firebase | New addition — Realtime Database enabled alongside your existing Firestore (different product, same project), used purely as an event mirror. |
