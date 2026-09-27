# DFPlayer Mini — Two-Language (Kannada + English) Setup & Test Guide

> **Folder numbering note:** this matches your final spec —
> **folder `01` = Kannada**, **folder `02` = English**. This is already
> implemented in `arduino_uno_final.ino` via `LANG_KANNADA = 1` and
> `LANG_ENGLISH = 2` — you only need this guide for preparing/testing
> the SD card itself, not for wiring the button (that's done).

## 1. Why you need TWO folders, not one

Your Kannada and English tables both use track numbers 001–025.
DFPlayer can't have two files both named `008.mp3` in the same folder —
so each language gets its own folder, and the code picks the folder at
runtime based on the selected language.

```
SD Card (root)
├── 01/          ← Kannada
│   ├── 001.mp3  (ಬೀಪ್)
│   ├── 002.mp3  (ದಯವಿಟ್ಟು ನಿಮ್ಮ ಕಾರ್ಡ್ ಟ್ಯಾಪ್ ಮಾಡಿ.)
│   ├── ...
│   └── 025.mp3  (ಕನ್ನಡ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ.)
└── 02/          ← English
    ├── 001.mp3  (beep)
    ├── 002.mp3  (Please tap your card.)
    ├── ...
    └── 025.mp3  (English language selected.)
```

Same naming rules as always apply **inside each folder**: exactly 3
digits + `.mp3`, folder named `01`/`02` (two digits, not `1`/`2`).

## 2. File content reference (both folders side by side)

| # | Kannada (folder 01) | English (folder 02) |
|---|---|---|
| 001 | ಬೀಪ್ | Beep |
| 002 | ದಯವಿಟ್ಟು ನಿಮ್ಮ ಕಾರ್ಡ್ ಟ್ಯಾಪ್ ಮಾಡಿ. | Please tap your card. |
| 003 | ಪ್ರವೇಶ ಯಶಸ್ವಿಯಾಗಿದೆ. ನಮ್ಮ ಬಸ್‌ಗೆ ಸ್ವಾಗತ. | Entry successful. Welcome aboard. |
| 004 | ನಿರ್ಗಮನ ಯಶಸ್ವಿಯಾಗಿದೆ. ನಮ್ಮೊಂದಿಗೆ ಪ್ರಯಾಣಿಸಿದ್ದಕ್ಕಾಗಿ ಧನ್ಯವಾದಗಳು. | Exit successful. Thank you for travelling with us. |
| 005 | ಅಮಾನ್ಯ ಕಾರ್ಡ್. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. | Invalid card. Please try again. |
| 006 | ನಿಮ್ಮ ಕಾರ್ಡ್‌ನಲ್ಲಿ ಸಾಕಷ್ಟು ಹಣವಿಲ್ಲ. ದಯವಿಟ್ಟು ರೀಚಾರ್ಜ್ ಮಾಡಿ. | Insufficient balance. Please recharge your card. |
| 007 | ಕೆಂಪೇಗೌಡ ಬಸ್ ನಿಲ್ದಾಣಕ್ಕೆ ಸ್ವಾಗತ... | Welcome to Kempegowda Bus Station... |
| 008 | ಮುಂದಿನ ನಿಲ್ದಾಣ: ಮಹಾರಾಣಿ ಕಾಲೇಜು. | Next stop: Maharani College. |
| 009–023 | *(remaining stops, Kannada)* | *(remaining stops, English)* |
| 024 | ...ಅಂತಿಮ ನಿಲ್ದಾಣ. ಧನ್ಯವಾದಗಳು. | ...final stop. Thank you... |
| 025 | ಕನ್ನಡ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ. | English language selected. |

(Full text for every stop is in the two tables you already prepared —
copy each language's files into its matching folder using those exact
filenames.)

---

## 3. Test sketch — verify BOTH folders before touching your main code

Run this standalone first, before flashing `arduino_uno_final.ino`, so
SD-card problems and application-logic problems never get tangled
together while you debug:

```cpp
#include <SoftwareSerial.h>
#include <DFRobotDFPlayerMini.h>

SoftwareSerial dfSerial(2, 3); // RX, TX — match your wiring
DFRobotDFPlayerMini player;

void setup() {
  Serial.begin(9600);
  dfSerial.begin(9600);

  Serial.println(F("Connecting to DFPlayer..."));
  if (!player.begin(dfSerial)) {
    Serial.println(F("DFPlayer not found — check wiring/SD card"));
    while (true);
  }
  player.volume(25); // 0-30

  Serial.println(F("=== DFPlayer 2-Language Test ==="));
  Serial.println(F("Type: <folder> <track>  e.g.  1 8   (Kannada, stop 8)"));
  Serial.println(F("                          or  2 8   (English, stop 8)"));
  Serial.println(F("Type 'A' to auto-play all 25 Kannada tracks in order"));
  Serial.println(F("Type 'B' to auto-play all 25 English tracks in order"));
}

void loop() {
  if (!Serial.available()) return;

  String line = Serial.readStringUntil('\n');
  line.trim();

  if (line.equalsIgnoreCase("A")) {
    playAllInFolder(1, "Kannada");
    return;
  }
  if (line.equalsIgnoreCase("B")) {
    playAllInFolder(2, "English");
    return;
  }

  int spaceIdx = line.indexOf(' ');
  if (spaceIdx == -1) {
    Serial.println(F("Format: <folder> <track>, e.g. '1 8'"));
    return;
  }

  int folder = line.substring(0, spaceIdx).toInt();
  int track  = line.substring(spaceIdx + 1).toInt();

  if ((folder != 1 && folder != 2) || track < 1 || track > 25) {
    Serial.println(F("Folder must be 1 or 2, track 1-25"));
    return;
  }

  Serial.print(F("Playing folder "));
  Serial.print(folder);
  Serial.print(F(" track "));
  Serial.println(track);
  player.playFolder(folder, track);
}

void playAllInFolder(int folder, const char* label) {
  Serial.print(F("--- Playing all 25 tracks: "));
  Serial.print(label);
  Serial.println(F(" ---"));
  for (int t = 1; t <= 25; t++) {
    Serial.print(F("Track "));
    Serial.println(t);
    player.playFolder(folder, t);
    delay(4000); // adjust if your clips are longer/shorter
  }
  Serial.println(F("--- Done ---"));
}
```

### How to test systematically

1. Upload the sketch, open **Serial Monitor**, set baud to **9600** and
   line ending to **"Newline"**
2. Type `1 1` and press Enter → should hear the Kannada beep
3. Type `2 1` and press Enter → should hear the English beep
4. Spot-check a few stop announcements from each folder: `1 8`, `2 8`,
   `1 24`, `2 24`
5. Once individual tracks sound right, run the full sweep: type `A` for
   all Kannada tracks back-to-back, then `B` for all English tracks —
   listen for any silent gaps (missing file) or wrong-sounding tracks
   (misnamed file)
6. Fix any SD card file naming before flashing `arduino_uno_final.ino`

---

## 4. Language switching in your main code — already done

`arduino_uno_final.ino` already implements the language button (pin
`A3`), the `currentLang` variable, and every `playFolder()` call using
it — you don't need to hand-edit anything for this part. This section
is kept only so you understand *why* it works: pressing the button
toggles between `LANG_KANNADA` (1) and `LANG_ENGLISH` (2), plays track
025 as a spoken confirmation in the newly selected language, and every
subsequent announcement uses that language until the button is pressed
again.
