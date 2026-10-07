# Smart Bus - Fixed Build Notes

Based on the supplied Flutter/Firebase project.

## Added

1. Admin RFID card ACTIVE / INACTIVE switch. Status is stored in `wallets/{RFID_UID}.active` and synchronized through the existing realtime Firestore wallet listener.
2. Flutter RFID simulator blocks inactive cards and records `CARD_INACTIVE` denied history.
3. Passenger Smart Card shows ACTIVE / ON BUS / INACTIVE.
4. New Admin Passenger Activity History panel with recent passenger activity and live ONBOARD summary.
5. Every supplied RFID card has 10 local prototype history records. Real Firestore transactions continue to merge into the same feed. Prototype records are display-only and are not uploaded automatically.
6. Flutter prototype fare calculation is aligned to ₹5 per travelled stop.

## Physical hardware note

The app stores the card status and can block its simulator flow. Physical Arduino/NodeMCU enforcement requires the hardware firmware to read the same `active` state. The app sends an optional POST to `/card-status` when `esp32Ip` is configured, but the current hardware firmware must implement that endpoint for physical enforcement.

## Run

From the extracted project folder:

```text
flutter clean
flutter pub get
flutter run
```

Flutter/Gradle machine-specific files such as `.dart_tool`, `android/.gradle`, `android/build`, and `android/local.properties` are intentionally not included.

## Firebase compatibility

Existing cards without an `active` field are treated as ACTIVE. New cards are created with `active: true`.
