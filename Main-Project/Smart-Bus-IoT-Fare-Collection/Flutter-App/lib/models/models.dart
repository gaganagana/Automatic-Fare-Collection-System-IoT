import 'package:flutter/foundation.dart';

/// A registered RFID smart-card / wallet.
class RfidWallet {
  final String uid; // hex UID as read by the MFRC522, e.g. "CAFEBABE"
  String holderName;
  double balance;
  bool onboard; // true = currently on the bus (last tap was a Boarding)

  RfidWallet({
    required this.uid,
    required this.holderName,
    required this.balance,
    this.onboard = false,
  });
}

enum TxType { boarding, exit, recharge, denied }

extension TxTypeLabel on TxType {
  String get label {
    switch (this) {
      case TxType.boarding:
        return 'BOARDING';
      case TxType.exit:
        return 'EXIT';
      case TxType.recharge:
        return 'RECHARGE';
      case TxType.denied:
        return 'DENIED';
    }
  }
}

/// One row in the "Live Transaction Feed" table.
class FareTransaction {
  final DateTime time;
  final String uid;
  final String holder;
  final TxType type;
  final String stop;
  final double amount; // negative = debit, positive = credit
  final double balanceAfter;

  FareTransaction({
    required this.time,
    required this.uid,
    required this.holder,
    required this.type,
    required this.stop,
    required this.amount,
    required this.balanceAfter,
  });
}

/// A stop along the fixed Bengaluru route.
class RouteStop {
  final String id; // S01, S02 ...
  final String name;
  final double fare;
  final String audioTrack; // e.g. "002.mp3"
  final double x; // normalised 0..1 position on the schematic map (fallback)
  final double y;
  final double lat; // real-world coordinates, used by the Google Maps view
  final double lng;

  const RouteStop({
    required this.id,
    required this.name,
    required this.fare,
    required this.audioTrack,
    required this.x,
    required this.y,
    required this.lat,
    required this.lng,
  });
}

enum UserRole { admin, passenger }

UserRole roleFromString(String? value) =>
    value == 'admin' ? UserRole.admin : UserRole.passenger;

String roleToString(UserRole role) => role == UserRole.admin ? 'admin' : 'passenger';

/// A signed-in user's profile. The Firebase Authentication UID is the
/// source of truth for identity (email + hashed password live there,
/// managed entirely by Google); `role` and `linkedUid` are the
/// AUTHORIZATION data and come from the matching document in the
/// Firestore "users" collection — see AuthService.
class UserAccount {
  final String uid; // Firebase Auth UID
  final String username;
  final String email;
  final UserRole role;
  final String? linkedUid; // for passenger accounts, which RFID card they own

  const UserAccount({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    this.linkedUid,
  });
}

@immutable
class TelemetryStatus {
  final bool esp32Connected;
  final bool gpsOk;
  final bool irOk;
  final DateTime? lastPing;

  const TelemetryStatus({
    this.esp32Connected = false,
    this.gpsOk = true,
    this.irOk = true,
    this.lastPing,
  });

  TelemetryStatus copyWith({
    bool? esp32Connected,
    bool? gpsOk,
    bool? irOk,
    DateTime? lastPing,
  }) {
    return TelemetryStatus(
      esp32Connected: esp32Connected ?? this.esp32Connected,
      gpsOk: gpsOk ?? this.gpsOk,
      irOk: irOk ?? this.irOk,
      lastPing: lastPing ?? this.lastPing,
    );
  }
}
