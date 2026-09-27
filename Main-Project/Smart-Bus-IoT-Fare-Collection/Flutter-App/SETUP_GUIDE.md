# Smart Bus — Setup Guide

This project has two parts:

```
smart_bus_app/
├── lib/                  <- Flutter dashboard app
├── esp32/
│   └── smart_bus_fare_gate.ino   <- ESP32 hardware sketch
├── pubspec.yaml
└── SETUP_GUIDE.md        <- you are here
```

Authentication is real: **Firebase Authentication** handles sign-in
(passwords are hashed by Google, never stored in this code), and a
**Firestore** `users` collection stores each account's role
(`admin`/`passenger`) and, for passengers, which RFID card they own.
That means you must create a free Firebase project before the app will
run — section 2 below walks through it, it takes about 10 minutes.

---

## 1. Install prerequisites

1. Install **Flutter SDK**: https://docs.flutter.dev/get-started/install
2. Verify your setup:
   ```bash
   flutter doctor
   ```
   Fix anything marked with a red ✗ before continuing.
3. Install **Android Studio** (also installs the Android SDK) and add the
   **Flutter** plugin inside it (Settings → Plugins → search "Flutter").
4. Unzip this project, open a terminal inside `smart_bus_app/`, and generate
   the missing native platform folders (they're not shipped in the zip,
   `flutter create` adds them without touching your existing `lib/` code):
   ```bash
   flutter create --platforms=android,ios .
   ```
5. Fetch dependencies:
   ```bash
   flutter pub get
   ```
6. Generate the real app icon and splash screen from the included assets
   (one-time step — makes the app show its own bus/RFID icon and a matching
   dark splash screen instead of the generic default Flutter icon):
   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

---

## 2. Create your Firebase project (required — do this before running)

1. Go to https://console.firebase.google.com → **Add project** → name it
   e.g. `smart-bus-fare-system` → finish the wizard (Google Analytics is
   optional, you can turn it off).
2. **Enable Authentication**: left sidebar → **Build → Authentication** →
   **Get started** → **Sign-in method** tab → enable **Email/Password**.
3. **Enable Firestore**: left sidebar → **Build → Firestore Database** →
   **Create database** → start in **test mode** for now (locks down for
   real use in step 6 below) → pick any region close to you.
4. **Register your Android app**: Project settings (gear icon) →
   **Your apps** → Android icon →
   - Android package name: use whatever is in
     `smart_bus_app/android/app/build.gradle` under `applicationId`
     (default is `com.example.smart_bus_dashboard` unless you changed it)
   - Download `google-services.json` when prompted — keep it, you'll place
     it in step 5.
5. **Install the FlutterFire CLI** and connect this project to Firebase:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   - Pick the Firebase project you just created
   - Select **android** (and **ios** if you're building for iPhone)
   - This automatically overwrites `lib/firebase_options.dart` with your
     real project keys, and drops `google-services.json` /
     `GoogleService-Info.plist` into the right native folders for you —
     you don't need to manually copy the file from step 4 if this step
     succeeds.
6. **(Recommended) Lock down Firestore rules** before you forget — Firebase
   Database → Rules, replace the default with:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read: if request.auth != null && request.auth.uid == userId;
         allow create: if request.auth != null && request.auth.uid == userId;
         allow update, delete: if false;
       }
     }
   }
   ```
   This means a signed-in user can only read/create *their own* profile
   document, and nobody can edit a `role` field from the client after
   creation — exactly what you want for a real authorization system.

---

## 3. Create your first Admin account

The app's Register screen only creates **passenger** accounts on
purpose — you don't want a public "become admin" button. Create the one
admin account by hand:

1. Firebase Console → **Authentication → Users → Add user** → enter an
   email + password → **Add user**. Copy the **User UID** shown in the
   table.
2. Firebase Console → **Firestore Database → Start collection** → collection
   ID `users` → Document ID: paste the UID you just copied → add fields:
   | Field | Type | Value |
   |---|---|---|
   | `email` | string | the same email you used above |
   | `username` | string | `admin` (or whatever you like) |
   | `role` | string | `admin` |
   | `linkedUid` | string | *(leave blank / null)* |
3. Save. That email/password now logs into the full Control Room
   dashboard in the app.

Passenger accounts don't need this manual step — anyone can tap **"New
passenger? Register a card account"** on the Login screen, which creates
their Firebase Auth account and their Firestore profile (role =
`passenger`) in one go, linked to whichever RFID UID they enter (use one
of the demo UIDs from section 5, or register a new card first from the
admin dashboard).

---

## 4. Run the app

```bash
flutter devices     # confirm a phone or emulator is attached
flutter run
```

You'll land on the **Login screen**. Use the admin account you created
in section 3, or register a new passenger account from the same screen.
On success, a real confirmation email is sent (see section 7 to wire
that up) and — for admins — the full Control Room dashboard opens; for
passengers, a restricted view of just their own card and trip history.

> **Why a phone/tablet and not just a browser?** The app runs a small
> embedded HTTP server (`shelf`) so the physical ESP32 can talk to it
> directly over WiFi. That server only works on Android/iOS/desktop
> builds, not `flutter run -d chrome`.

---

## 5. Localization, accessibility & voice announcements (English + Kannada)

The app supports two languages (English + Kannada) and speaks key events
out loud via text-to-speech — useful for low-literacy or visually impaired
riders, and a good talking point for your accessibility/inclusivity
angle in the project report.

1. First run of the app after `flutter pub get`, Flutter's build step
   automatically runs the localization generator (`generate: true` is
   set in `pubspec.yaml`, reading `l10n.yaml`) and creates
   `lib/l10n/generated/app_localizations.dart` — you don't need to run
   anything extra for this specifically, just `flutter run` once.
   - If you ever want to trigger it manually (e.g. after editing an
     `.arb` file without doing a full run): `flutter gen-l10n`
2. In the running app, look at the header bar — you'll see an **EN / ಕನ್ನಡ**
   toggle button. Tap it to switch every on-screen label between English
   and Kannada instantly.
3. The 🔊 speaker icon next to it mutes/unmutes voice announcements
   without changing the language.
4. Trigger a voice announcement to test it: tap **Start Simulator** (the
   bus announces the next stop as it "arrives"), or tap one of the
   **Simulate RFID Tap** buttons (announces boarding/exit/denied in
   whichever language is currently selected).

### Kannada voice on your device
Whether you actually hear a Kannada voice (vs. it silently falling back
to English) depends on your device having a Kannada TTS voice installed:
- **Android:** Settings → System → Languages & input → Text-to-speech
  output → gear icon next to your engine (usually "Google") → Install
  voice data → download Kannada
- **iOS:** Settings → Accessibility → Spoken Content → Voices → find
  Kannada (availability varies by iOS version/device)

### Adding more translated strings later
Every UI string doesn't have to be translated on day one — only the
header, login screen, status card, and TTS announcements are wired up
as a working example. To localize more screens:
1. Add a new key to **both** `lib/l10n/app_en.arb` and `lib/l10n/app_kn.arb`
   (same key name, English text in one, Kannada in the other)
2. Re-run (or just `flutter run` again — codegen re-runs automatically)
3. Use it in any widget: `AppLocalizations.of(context)!.yourNewKey`

### How the TTS integration works (for your viva)
`AppState` (in `lib/state/app_state.dart`) calls `tts.speak(...)` directly
inside the fare logic — e.g. the moment a boarding tap is approved, or the
simulator advances to a new stop — using
`lookupAppLocalizations(locale)`, which is the same generated
translation lookup the UI uses, just called without a BuildContext (since
AppState isn't a widget). This is what keeps the spoken language and the
on-screen language from ever drifting out of sync with each other.

---

## 6. Using the dashboard (no hardware required yet)

- Click **START SIMULATOR** in the header — the bus marker animates along
  the route on the live map, the current/next stop blocks update, and
  speed/status metrics change automatically.
- In the **"SIMULATE RFID TAP"** panel, click a passenger's name to
  simulate a physical tap — this exercises the exact same code path a
  real ESP32 tap would (fare deduction, ENTERED/EXITED counters, live
  transaction row, sliding SMS banner).
- Click **RECHARGE** on any RFID Wallet card to try the simulated
  PhonePe/Google Pay flow (2-second "SDK handshake" spinner, then balance
  updates and a new feed row appears).
- **REGISTER NEW RFID** lets you add new cards with a UID + holder name.

### Registered demo cards (pre-loaded, no setup needed)
| Holder      | UID        | Starting balance |
|-------------|------------|-------------------|
| Meera Nair  | CAFEBABE   | ₹320              |
| Rohan Kumar | A1B2C3D4   | ₹180              |
| Priya Iyer  | 9F8E7D6C   | ₹60               |
| Arjun Rao   | 11AA22BB   | ₹250              |

---

## 7. Connecting the real ESP32 hardware

1. Open `esp32/smart_bus_fare_gate.ino` in the Arduino IDE.
2. Install these libraries via **Tools → Manage Libraries**:
   - `MFRC522` (by GithubCommunity)
   - `ArduinoJson` (v6.x, by Benoit Blanchon)
3. Install the **esp32** board package via **Boards Manager** if you
   haven't already (Espressif Systems).
4. Wire the hardware per the pin map at the top of the `.ino` file
   (MFRC522 over SPI, L293D for the gate motor, a GPIO trigger pin for
   your voice module, an LED + buzzer for denial feedback) — matches the
   breadboard layout in your photo (Arduino/ESP32, RFID-RC522, L293D
   driver, DC motor, speaker, LCD).
5. Edit the top of the sketch:
   ```cpp
   const char* WIFI_SSID     = "YOUR_WIFI_SSID";
   const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";
   String SERVER_HOST = "192.168.1.100"; // phone's IP — see next step
   ```
6. **Find your phone's IP address**: with the app running on the same
   WiFi as the ESP32, check Settings → WiFi → tap the connected network.
   Put that IP into `SERVER_HOST` above, and also paste it into the
   **"ESP32 board local IP"** field in the app's Telemetry Source panel,
   then tap **SAVE**.
7. Flash the sketch (select the correct board + COM port, then **Upload**).
8. Open the Arduino IDE **Serial Monitor** at 115200 baud — you should see
   `WiFi connected. ESP32 IP: ...` then `Card tapped, UID: ...` per tap.
9. The dashboard's **START SIMULATOR** button also starts the embedded
   HTTP server on port `8080`. The first successful tap turns the ESP32
   status dot in "Telemetry Source" green.

### Test the link without a working RFID card
```bash
curl -X POST http://<phone-ip>:8080/api/bus/telemetry \
  -H "Content-Type: application/json" \
  -d '{"uid":"CAFEBABE"}'
```
You should get back `{"status":"APPROVED", ...}` and see a new row appear
instantly in the app's Live Transaction Feed.

---

## 8. Real login emails (SMTP)

`lib/services/email_service.dart` sends a real email every time someone
logs in or registers successfully.

1. Use a Google account you control (a throwaway one is fine).
2. Turn on **2-Step Verification**: Google Account → Security.
3. Create an **App Password**: Google Account → Security → App passwords
   → generate one for "Mail". You'll get a 16-character code.
4. Open `lib/services/email_service.dart` and set:
   ```dart
   static const String senderEmail = 'youraddress@gmail.com';
   static const String senderAppPassword = 'xxxx xxxx xxxx xxxx'; // the app password, not your real Gmail password
   ```
5. Rebuild, log in with a real email address you can check, and look for
   the notification (check spam the first time).

**Security note for later:** shipping an SMTP credential inside a
compiled mobile app is fine for a college project/demo, but not for a
public release — before publishing for real, move the `mailer` call into
a small backend (a Firebase Cloud Function is a natural fit since you
already have a Firebase project) and have the app call that over HTTPS
instead of holding the SMTP password itself.

---

## 9. Building a release APK — install once, run forever (no computer needed)

Everything so far used `flutter run`, which needs your computer connected
every time. For daily use (and for your final demo/viva), build a real
installable app instead.

### Step 1 — allow local HTTP traffic (required, one-time)
Your embedded ESP32 server uses plain HTTP on your home/college WiFi, not
HTTPS. Android release builds block plain HTTP by default, so without this
step the ESP32 connection will silently stop working the moment you switch
from `flutter run` to a release APK (Firebase still works fine either way,
since it always uses HTTPS — this only affects the ESP32 link).

1. After you've run `flutter create --platforms=android,ios .` (section 1),
   open this file in Android Studio (or any text editor):
   ```
   android/app/src/main/AndroidManifest.xml
   ```
2. Find the `<application ...>` opening tag near the top and add one
   attribute to it:
   ```xml
   <application
       android:label="smart_bus_dashboard"
       android:usesCleartextTraffic="true"
       ...>
   ```
   (Just add `android:usesCleartextTraffic="true"` as a new line inside
   the existing `<application>` tag — don't remove anything already there.)

This tells Android "plain HTTP is allowed for this app," which is fine
here since the embedded server only ever talks to your own ESP32 on your
own local WiFi network, never the public internet.

### Step 2 — build the release APK
In your project's terminal:
```bash
flutter build apk --release
```
This takes a few minutes. When it finishes, the installable file is at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 3 — install it on your phone
- Transfer that `.apk` file to your phone (email it to yourself, Google
  Drive, or a USB cable — any method works, it's just a file)
- Tap it on your phone to install
- Android will likely show **"Install blocked"** the first time — tap
  **Settings** in that prompt, allow installs from that source (Files app
  / Drive / whatever you used), go back, and install
- Once installed, it's a normal app icon on your home screen — open it
  directly any time, no computer, no `flutter run`, ever again

### A few things to know about the installed app
- **Firebase login still needs internet** (WiFi or mobile data) — that
  part was never dependent on your computer anyway
- **The ESP32 connection needs the phone on the same WiFi as the board**,
  exactly like before — that hasn't changed, only how you launch the app
  has
- **To update the app later** (e.g. after you change some code), you
  repeat steps 2–3 — build a new APK and reinstall it. Android will
  overwrite the old version and keep it as one app, not a duplicate

---

## 10. Real Google Maps setup (required for the live map to render)

The dashboard now shows an actual Google Map with real Bengaluru streets,
real stop markers, and a bus icon that moves along real coordinates —
this replaced the earlier dependency-free schematic map. This needs one
thing from you: a free Google Maps API key.

### Step 1 — Get an API key
1. Go to https://console.cloud.google.com/google/maps-apis
2. Create a new project (or pick an existing one) — top-left project
   selector → New Project → name it → Create
3. Left menu → APIs & Services → Library → search "Maps SDK for
   Android" → Enable. Repeat for "Maps SDK for iOS" if you'll build for
   iOS too
4. Left menu → APIs & Services → Credentials → Create Credentials →
   API Key — copy the key shown
5. **Enable billing on the project** — Google requires a billing account
   attached to activate the API key, as an identity/anti-abuse step.
   Good news specific to this project: the **Maps SDK for Android/iOS**
   (what `google_maps_flutter` actually uses) is **free with unlimited
   usage** — no per-load charge, no monthly cap. You will not be billed
   for displaying the map, markers, or route line, no matter how much
   you use it. (This project doesn't call Places, Directions, or
   Geocoding APIs, which are the ones that do have usage-based costs
   above a free monthly tier.)
6. Optional but recommended: click your new API key → under
   "Application restrictions" pick "Android apps" → add your app's
   package name (found in `android/app/build.gradle`, the
   `applicationId` line) and its SHA-1 fingerprint (Android Studio →
   Gradle panel → your app → Tasks → android → signingReport, then
   copy the SHA1 value) — this restricts the key so nobody else can use
   it if it leaks

### Step 2 — Add the key to your Android project
1. Open `android/app/src/main/AndroidManifest.xml`
2. Inside the `<application>` tag, add:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_KEY_HERE" />
   ```

### Step 3 — Add the key to your iOS project (only if building for iOS)
1. Open `ios/Runner/AppDelegate.swift`
2. Add near the top: `import GoogleMaps`
3. Inside `application(_:didFinishLaunchingWithOptions:)`, add:
   `GMSServices.provideAPIKey("YOUR_KEY_HERE")`

### Step 4 — Run it
```bash
flutter pub get
flutter run
```
The Live Bus Location card now shows a real map. Tap Start Simulator —
the amber bus marker moves smoothly along real streets between the real
coordinates set for each of your 18 stops.

### A note on the coordinates themselves
The lat/lng for each stop in `lib/mock_data.dart` are reasonable
approximations for the named Bengaluru landmarks (Kempegowda Bus
Station, KR Circle, Lalbagh, Jayanagar, etc.), not laser-precise
addresses. If you want to fine-tune any of them: open Google Maps in a
browser, right-click the exact spot, click the coordinates that pop up
to copy them, and paste the `lat`/`lng` values into the matching
`RouteStop` entry in `lib/mock_data.dart`.

### If the map shows blank / grey tiles
This is almost always one of: API key missing from AndroidManifest.xml,
Maps SDK for Android not enabled in step 1.3, or billing not enabled in
step 1.5 — check these three in order, in that order of likelihood.

---

## 11. Project structure reference

```
l10n.yaml                           # tells Flutter where the .arb files + generated output live
lib/
├── main.dart                     # Firebase bootstrap + localization + role-based routing
├── firebase_options.dart         # generated by `flutterfire configure`
├── theme.dart                    # dark "control room" theme
├── mock_data.dart                # seed wallets + route stops
├── l10n/
│   ├── app_en.arb                # English source strings (template)
│   ├── app_kn.arb                # Kannada translations
│   └── generated/                # auto-created by the l10n codegen — don't hand-edit
├── models/models.dart            # RfidWallet, FareTransaction, RouteStop, AppUser/UserAccount
├── state/app_state.dart          # single source of truth (Provider/ChangeNotifier) + TTS triggers
├── services/
│   ├── auth_service.dart         # Firebase Auth + Firestore role lookups
│   ├── telemetry_server.dart     # embedded HTTP server for the ESP32
│   ├── email_service.dart        # SMTP login-notification emails
│   └── tts_service.dart          # text-to-speech wrapper (flutter_tts)
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart      # passenger self-registration
│   ├── firebase_setup_needed_screen.dart  # friendly screen if Firebase isn't configured yet
│   ├── admin_dashboard_screen.dart
│   └── passenger_screen.dart
└── widgets/
    ├── header_bar.dart           # includes the EN/KN + voice-mute toggles
    ├── metric_card.dart          # includes the Semantics/TalkBack wiring
    ├── current_route_block.dart
    ├── live_map.dart
    ├── transaction_table.dart
    ├── telemetry_panel.dart
    ├── rfid_wallet_panel.dart
    ├── route_timeline.dart
    └── sms_banner.dart
```

---

## 12. What's real vs. simulated — and how to explain it in your viva

This project deliberately mixes real integrations with simulated ones, matching the original project scope. Being able to state this clearly and confidently is worth more in a viva than pretending everything is fully real.

### Genuinely real (not mocked)
| Feature | What makes it real |
|---|---|
| Login / authentication | Firebase Authentication — passwords hashed server-side by Google (scrypt), not stored or checked by your own code |
| Database | Cloud Firestore (user roles) + Realtime Database (hardware events) — actual cloud databases, not local files |
| Hardware communication | Real UART between Arduino UNO and ESP32, real HTTP/WiFi between ESP32 and the phone app |
| Email | Real SMTP via Gmail — an actual email arrives in a real inbox |
| Voice announcements | Real text-to-speech (flutter_tts on the app side, DFPlayer Mini audio files on the hardware side) |
| Bilingual support | Real localization system (Flutter's l10n codegen), not hardcoded strings swapped by hand |

### Deliberately simulated (by original design, not a shortcut)
| Feature | What's simulated | Why |
|---|---|---|
| PhonePe / Google Pay recharge | The payment gateway itself — no real money moves | A real integration needs PhonePe/Razorpay merchant KYC, which isn't obtainable for a student project |
| SMS alert banner | It's an in-app banner styled like an SMS notification — no real SMS is sent to a phone number | A real SMS gateway (Twilio, Fast2SMS) costs per-message and needs a business account |

### If an examiner asks about either of these
A clear, confident answer that shows you understand the distinction (this is a strength to demonstrate, not something to hide):

> "I implemented a simulated PhonePe/GPay flow and an SMS-style in-app notification, matching the scope of a student project. A real integration would need PhonePe merchant KYC and an SMS gateway account, which aren't accessible for coursework — but the UX and code structure show exactly where a real gateway would plug in."

This is a stronger answer than either overclaiming ("yes it's fully real") or being defensive about it — it shows you made a deliberate, informed scoping decision.

---

## 13. Common issues — now mostly self-diagnosing

Several of these used to require digging through logs; the app now
surfaces them directly:

- **`flutterfire configure` or `flutter pub get` fails / hangs** — check
  your internet connection; some college/lab networks block `pub.dev` and
  Firebase endpoints, try a mobile hotspot. (Not fixable in-app — it's a
  network reachability issue before the app even runs.)
- **`Firebase.initializeApp` throws "no options for this platform"** — the
  app no longer crashes on this. It now shows a **"Firebase isn't
  configured yet"** screen with the exact two commands to run
  (`flutterfire configure`) instead of a blank/red error screen.
- **Login says "This account has no role assigned"** — the Firestore
  `users/{uid}` document is missing or misspelled. Re-check section 3 —
  the field must be named exactly `role` with value `admin` or
  `passenger`.
- **App builds but ESP32 taps never arrive** — the telemetry server now
  starts automatically the moment the app launches (you no longer need to
  press Start Simulator first), auto-retries on the next 5 ports if 8080
  is already taken, and the **Telemetry Source** panel now shows this
  device's own WiFi IP directly (with a copy button) plus any bind error
  in plain English — no more hunting through phone Settings. Phone and
  ESP32 still need to be on the **same WiFi network** (not campus WiFi
  with client isolation — use a mobile hotspot for the demo if needed).
- **Emails not arriving / failing silently** — the app now checks whether
  you've actually edited `email_service.dart`'s placeholder credentials
  before attempting to send, and shows a banner in the app explaining
  exactly why an email didn't go out (not configured yet / wrong app
  password / no internet) instead of only logging to the console.
- **Gate motor doesn't move** — hardware wiring issue, not fixable in
  software: the L293D needs its own motor supply voltage on `VCC2`/`VS`
  (not powered from the ESP32's 3.3 V rail), with a common ground to the
  ESP32.
- **Red error: "Target of URI doesn't exist: 'l10n/generated/app_localizations.dart'"**
  — this file is auto-generated, not shipped in the zip. Run `flutter run`
  or `flutter pub get` once (with `generate: true` already set in
  `pubspec.yaml`) and it's created automatically; if it still doesn't
  appear, run `flutter gen-l10n` directly.
- **Language switches but the voice still speaks English** — the device
  doesn't have a Kannada TTS voice installed yet. This is a device/OS
  setting, not an app bug — see section 5's "Kannada voice on your
  device" for exactly where to install it.
