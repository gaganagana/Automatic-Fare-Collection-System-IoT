# Smart Bus Final Prototype - Implementation Checklist

## Included in this source package

### Hardware integration target
- Arduino UNO: RFID, fare/entry-exit logic, LCD, motor/servo, DFPlayer announcements.
- NodeMCU: Arduino event receiver, Wi-Fi/Firebase bridge target, green/red LEDs.
- Existing A2 -> 1K -> D2 with 2K to common GND is preserved.
- NodeMCU D1 remains unused/disconnected in the current one-way hardware design.

### Firebase
- Firebase Authentication for login.
- Firestore `users` for authorization/profile.
- Firestore `wallets` for RFID card state and balance.
- Firestore `transactions` for journey, recharge and denied events.
- Role-based access: `admin` and `passenger`.
- Passenger transactions are filtered by the signed-in Firebase UID.
- Prototype history is filtered per passenger; admins can see the complete prototype feed.

### User dashboard
- Profile/welcome.
- Smart Card with masked RFID, status, balance, onboard state, entry/exit/fare/time.
- Razorpay TEST MODE recharge.
- Recharge and journey records in the same transaction model, visually distinguished.
- Notification center derived from the passenger's own events.
- Journey/recharge/access-attempt detail dialog.
- Current/next stop and fixed prototype route.
- AI Smart Bus Assistant.
- Help & Support -> admin email.
- No real-money payment processing is enabled by this source package.

### Admin dashboard
- Bus status and current stop.
- Live transaction feed.
- Passenger management.
- RFID card management.
- AI/route assistant.
- Travel analytics.
- Telemetry panel.
- Route timeline.
- Demo RFID tap panel remains removed.

### Prototype users/cards
Admin:
- Gagana -> gaganacp2002@gmail.com

Passengers:
- Karthik -> 63E6D51D -> gaganagana0822@gmail.com
- Gayathri -> F0C27F5F -> EMAIL LEFT BLANK UNTIL A SEPARATE ADDRESS IS AVAILABLE
- Nharika -> 90444455 -> niharikarm123@gmail.com
- Bhanu Prakash -> 5402BBA9 -> crazysky2201@gmail.com
- Kanthesh -> 5B850B1A -> pp761254@gmail.com
- Shyamala -> 3D085006 -> skycrazy803@gmail.com
- Prema -> 21DB3E0A -> gaganaprema22@gmail.com

Prototype starting balances:
- Normal cards: ₹200
- Shyamala: ₹5
- Prema: ₹5

## Important setup

1. Run `flutter pub get`.
2. Replace the Razorpay TEST key in `lib/services/payment_service.dart` with YOUR OWN Razorpay TEST Key ID. Never put a Razorpay Key Secret in Flutter.
3. Configure Firebase for the target Android/iOS/Web platforms as required by your local Flutter project.
4. Create Firebase Authentication accounts with passwords you choose yourself.
5. Create matching Firestore `users/{firebaseAuthUid}` documents. Use the `linkedUid` value above.
6. Create the `wallets/{RFID_UID}` documents using the card values above.
7. Do not create Gayathri's Authentication account until a separate email is available.
8. Deploy `firestore.rules` after reviewing it for your Firebase project.
9. The prototype history is local display seed data; it is not automatically uploaded to Firestore.
10. Real hardware events should be sent through the existing telemetry/event interface and then persisted against the linked Firebase user.

## Payment safety
Razorpay TEST MODE is intended for development. The Flutter application must only contain a test Key ID. Payment order creation/signature verification should be handled by a trusted backend when moving beyond a classroom prototype.

## Scope boundary
GPS is represented by the fixed 18-stop route simulation. SMS is represented by an in-app notification/banner layer unless a real SMS provider is added separately. Travel analytics are prototype statistical analytics, not a trained ML model.
