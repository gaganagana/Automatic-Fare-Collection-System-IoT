# Smart Bus Flutter Prototype — Updated

This version keeps the existing Firebase Authentication + Firestore authorization model.

Updates:
- RFID cards are synchronized from Firestore in real time for the admin dashboard.
- Registered cards show only the holder name by default; tap a name to reveal UID/balance/status.
- Added LOW / MEDIUM / HIGH passenger-traffic classification to the dashboard.
- Added a passenger-side Smart Bus route assistant using the fixed prototype route, plus local traffic/travel analysis.
- Kept the schematic/fixed route as a prototype; no real GPS movement is required.
- Existing Firebase Auth/authorization and Firestore rules were preserved.
- Existing Flutter/Gradle/package versions were not intentionally upgraded.

## Supplied prototype card mapping

The seven hardware cards are mapped in `FIREBASE_USER_SETUP.md`. Firebase Authentication accounts must be created separately because passwords and Firebase Auth UIDs are not stored in source code. Note that `gaganacp2002@gmail.com` was supplied for both Gayathri and admin Gagana; Firebase cannot use one email for two accounts, so that conflict must be resolved before creating both accounts.

## Prototype identity data

The supplied seven RFID cards and passenger names are seeded in `lib/mock_data.dart` and documented in `FIRESTORE_DATA_TEMPLATE.json`. Firebase Auth accounts must still be created separately.

## Prototype transaction history

The passenger dashboard includes a small local prototype history so the UI is useful before Firestore contains real transactions. It includes completed journeys, entry records, invalid-card attempts, and low-balance denials with realistic dates and times. These prototype records are display-only and are not automatically written to Firestore.

## Fare timing rule

For the prototype simulator, boarding records the entry stop but does not deduct fare. Fare is calculated and deducted when the same card taps out, using the number of stops travelled (minimum fare: ₹5). Real hardware remains the source of truth for hardware-generated fare events.

## Card validity

A card is invalid when its RFID UID is not registered in the card database or does not exactly match a registered UID. A low-balance card is not an invalid card: it is recognized, but boarding is denied when the available amount is below the minimum fare requirement.


## Final prototype scope

- Arduino UNO + RFID + DFPlayer + LCD + motor + servo + route simulation
- NodeMCU connectivity + green/red event LEDs
- Firebase Authentication + role authorization
- Firestore users, cards/wallets, journeys and transactions
- Passenger Smart Card with live balance and Razorpay TEST MODE recharge
- Separate journey and recharge history with date/time
- Invalid-card and low-balance history
- Current/next stop and route timeline
- Notifications derived from passenger events
- Journey detail dialog
- Help & Support email to the administrator
- User-side Smart Bus AI route/history/card assistant
- Admin monitoring, card/passenger management and travel analytics

## New dashboard features in this fixed build

- Admin RFID panel now has an ACTIVE / INACTIVE switch for every registered card.
- Card status is stored in Firestore as `wallets/{RFID_UID}.active` and is synchronized in real time.
- Inactive cards are rejected by the Flutter simulator tap flow with `CARD_INACTIVE` history.
- Passenger Smart Card shows ACTIVE / ON BUS / INACTIVE status.
- Admin dashboard now includes a Passenger Activity History panel with recent passenger events and a live ONBOARD summary.
- Passenger dashboards show 10 realistic prototype history records for each of the seven supplied RFID cards until/alongside real Firestore transactions.
- Prototype history is display-only and is not uploaded to Firestore automatically.
- The project fare logic in the Flutter prototype is aligned to ₹5 per travelled stop.

### Card activation/deactivation

Admin: open **RFID Wallets** on the Admin Dashboard and use the switch beside a card. The change is written to Firestore immediately. Any open dashboard listening to the wallet collection receives the new status in real time.

The Flutter application blocks simulator RFID taps for an inactive card. For physical-bus enforcement, the NodeMCU/Arduino firmware must also consume the stored `active` flag (or the optional `/card-status` bridge endpoint); the Flutter app cannot change an Arduino's local card database by itself.
