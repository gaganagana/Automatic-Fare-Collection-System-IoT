import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';

import '../data_smart_bus_seed.dart';
import '../firebase_options.dart';
import '../models/models.dart';

/// Handles:
/// 1. Firebase Authentication
/// 2. Firestore user profiles
/// 3. Admin / Passenger authorization
/// 4. Passenger account creation
/// 5. Password reset
class AuthService {
  static final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // AUTH STATE
  // ============================================================

  /// Emits whenever Firebase login/logout/session state changes.
  static Stream<fb.User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  static fb.User? get currentFirebaseUser {
    return _auth.currentUser;
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  static Future<UserAccount> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty || password.isEmpty) {
      throw fb.FirebaseAuthException(
        code: 'invalid-input',
        message: 'Email and password are required.',
      );
    }

    try {
      // Firebase checks the email/password.
      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw fb.FirebaseAuthException(
          code: 'authentication-failed',
          message: 'Firebase did not return a user.',
        );
      }

      // Now check Firestore authorization.
      final profile = await _loadProfile(firebaseUser);

      if (profile == null) {
        // Authentication succeeded, but authorization failed.
        await _auth.signOut();

        throw fb.FirebaseAuthException(
          code: 'no-profile',
          message:
          'This account does not have a valid authorization profile.',
        );
      }

      return profile;
    } on fb.FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw fb.FirebaseAuthException(
        code: 'profile-load-failed',
        message: 'Could not load the user authorization profile: $e',
      );
    }
  }

  // ============================================================
  // LOAD FIRESTORE PROFILE
  // ============================================================

  static Future<UserAccount?> _loadProfile(
      fb.User firebaseUser,
      ) async {
    final email = (firebaseUser.email ?? '').trim().toLowerCase();

    // Match with known system passenger cards
    SmartBusSeedCard? matchedSeed;
    final cleanEmail = email.toLowerCase().trim();
    for (final s in smartBusSeedCards) {
      if (s.email.toLowerCase().trim() == cleanEmail && cleanEmail.isNotEmpty) {
        matchedSeed = s;
        break;
      }
    }

    final doc = await _db
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    final data = doc.data();

    // 1. Role determination:
    // Only the explicit system admin email (gaganacp2002@gmail.com) can ever be an admin.
    // Every other user, including Shyamala, Bhanu Prakash, etc., is strictly a Passenger.
    final isAdmin = cleanEmail == smartBusAdminEmail.toLowerCase().trim();
    final role = isAdmin ? UserRole.admin : UserRole.passenger;

    // 2. Username resolution:
    String username = (data?['username'] ?? '').toString().trim();
    if (username.isEmpty) {
      if (matchedSeed != null) {
        username = matchedSeed.holderName;
      } else if (isAdmin) {
        username = smartBusAdminName;
      } else if (cleanEmail.contains('shyamala')) {
        username = 'Shyamala';
      } else if (cleanEmail.contains('bhanu')) {
        username = 'Bhanu Prakash';
      } else if (cleanEmail.isNotEmpty) {
        username = cleanEmail.split('@').first;
      } else {
        username = 'Passenger';
      }
    }

    // Name-based seed fallback if email didn't match
    if (matchedSeed == null) {
      final nameLower = username.toLowerCase();
      if (nameLower.contains('shyamala') || cleanEmail.contains('shyamala') || cleanEmail.contains('803')) {
        matchedSeed = smartBusSeedCards.firstWhere((s) => s.uid == '3D085006');
      } else if (nameLower.contains('bhanu') || cleanEmail.contains('bhanu') || cleanEmail.contains('sky2201')) {
        matchedSeed = smartBusSeedCards.firstWhere((s) => s.uid == '5402BBA9');
      }
    }

    // 3. RFID Card UID resolution:
    String? linkedUid;
    if (isAdmin) {
      linkedUid = null;
    } else {
      if (data != null && data['linkedUid'] != null) {
        final val = data['linkedUid'].toString().trim().toUpperCase();
        if (val.isNotEmpty) linkedUid = val;
      }
      linkedUid ??= matchedSeed?.uid.toUpperCase();
      // Fail-safe default so no passenger is left without a card
      linkedUid ??= (username.toLowerCase().contains('bhanu') ? '5402BBA9' : '3D085006');
    }

    // 4. Auto-repair / Synchronize Firestore user document
    unawaited(_db.collection('users').doc(firebaseUser.uid).set({
      'username': username,
      'email': firebaseUser.email ?? cleanEmail,
      'role': isAdmin ? 'admin' : 'passenger',
      if (linkedUid != null) 'linkedUid': linkedUid,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)));

    // Auto-provision or update wallet in Firestore
    if (linkedUid != null && linkedUid.isNotEmpty) {
      final double startingBal = linkedUid == '5402BBA9'
          ? 10.0
          : (linkedUid == '3D085006' ? 5.0 : 200.0);
      unawaited(_db.collection('wallets').doc(linkedUid).set({
        'uid': linkedUid,
        'holderName': username,
        'balance': startingBal,
        'active': linkedUid != '21DB3E0A',
        'isDemo': false,
        'linkedFirebaseUid': firebaseUser.uid,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)));
    }

    return UserAccount(
      uid: firebaseUser.uid,
      username: username,
      role: role,
      email: firebaseUser.email ?? email,
      linkedUid: linkedUid,
    );
  }

  // ============================================================
  // LOAD CURRENT USER
  // ============================================================

  static Future<UserAccount?> loadProfileForCurrentUser() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    final profile = await _loadProfile(firebaseUser);

    // If Firebase says logged in but Firestore says unauthorized,
    // remove the Firebase session too.
    if (profile == null) {
      await _auth.signOut();
      return null;
    }

    return profile;
  }

  // ============================================================
  // PASSENGER SELF-REGISTRATION
  // ============================================================

  static Future<UserAccount> registerPassenger({
    required String email,
    required String password,
    required String username,
    required String linkedUid,
    double initialBalance = 200.0,
  }) async {
    final cleanEmail = email.trim();
    final cleanUsername = username.trim();
    final cleanLinkedUid = linkedUid.trim().toUpperCase();

    if (cleanEmail.isEmpty) {
      throw fb.FirebaseAuthException(
        code: 'invalid-email',
        message: 'Email is required.',
      );
    }

    if (cleanUsername.isEmpty) {
      throw fb.FirebaseAuthException(
        code: 'invalid-username',
        message: 'Username is required.',
      );
    }

    if (cleanLinkedUid.isEmpty) {
      throw fb.FirebaseAuthException(
        code: 'invalid-linked-uid',
        message: 'RFID card UID is required.',
      );
    }

    if (password.length < 6) {
      throw fb.FirebaseAuthException(
        code: 'weak-password',
        message: 'Password must be at least 6 characters.',
      );
    }

    fb.User? firebaseUser;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      firebaseUser = credential.user;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // If email already exists in Firebase Auth, automatically sign in with the provided password
        // to re-link the passenger profile and auto-provision the RFID card wallet in Firestore!
        try {
          final signInCred = await _auth.signInWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
          firebaseUser = signInCred.user;
        } catch (_) {
          throw fb.FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'That email is already registered. Please check the password or delete the user in the Firebase Console Authentication tab.',
          );
        }
      } else {
        rethrow;
      }
    }

    if (firebaseUser == null) {
      throw fb.FirebaseAuthException(
        code: 'registration-failed',
        message: 'Could not create or link the Firebase account.',
      );
    }

    // 1. Create or update user authorization profile in Firestore
    await _db
        .collection('users')
        .doc(firebaseUser.uid)
        .set({
      'username': cleanUsername,
      'email': cleanEmail,
      'role': 'passenger',
      'linkedUid': cleanLinkedUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Auto-provision or update RFID card wallet in Firestore
    await _db
        .collection('wallets')
        .doc(cleanLinkedUid)
        .set({
      'uid': cleanLinkedUid,
      'holderName': cleanUsername,
      'balance': initialBalance,
      'active': true,
      'onboard': false,
      'isDemo': false,
      'linkedFirebaseUid': firebaseUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return UserAccount(
      uid: firebaseUser.uid,
      username: cleanUsername,
      role: UserRole.passenger,
      email: cleanEmail,
      linkedUid: cleanLinkedUid,
    );
  }

  // ============================================================
  // CREATE PASSENGER FROM ADMIN
  // ============================================================

  /// Creates a passenger account without logging the current
  /// admin out.
  static Future<UserAccount> createPassengerAsAdmin({
    required String email,
    required String password,
    required String username,
    required String linkedUid,
  }) async {
    final cleanEmail = email.trim();
    final cleanUsername = username.trim();
    final cleanLinkedUid = linkedUid.trim().toUpperCase();

    if (cleanEmail.isEmpty) {
      throw fb.FirebaseAuthException(
        code: 'invalid-email',
        message: 'Email is required.',
      );
    }

    if (cleanUsername.isEmpty) {
      throw fb.FirebaseAuthException(
        code: 'invalid-username',
        message: 'Username is required.',
      );
    }

    if (cleanLinkedUid.isEmpty) {
      throw fb.FirebaseAuthException(
        code: 'invalid-linked-uid',
        message: 'RFID UID is required.',
      );
    }

    if (password.length < 6) {
      throw fb.FirebaseAuthException(
        code: 'weak-password',
        message: 'Password must be at least 6 characters.',
      );
    }

    // Secondary Firebase app prevents the current admin session
    // from being replaced by the newly-created passenger.
    final secondary = await Firebase.initializeApp(
      name:
      'passengerProvision_${DateTime.now().microsecondsSinceEpoch}',
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final secondaryAuth =
    fb.FirebaseAuth.instanceFor(app: secondary);

    try {
      final credential =
      await secondaryAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw fb.FirebaseAuthException(
          code: 'passenger-creation-failed',
          message: 'Firebase did not return the new passenger.',
        );
      }

      final passengerUid = firebaseUser.uid;

      await _db
          .collection('users')
          .doc(passengerUid)
          .set({
        'username': cleanUsername,
        'email': cleanEmail,
        'role': 'passenger',
        'linkedUid': cleanLinkedUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return UserAccount(
        uid: passengerUid,
        username: cleanUsername,
        role: UserRole.passenger,
        email: cleanEmail,
        linkedUid: cleanLinkedUid,
      );
    } finally {
      await secondaryAuth.signOut();
      await secondary.delete();
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  static Future<void> sendPasswordReset(
      String email,
      ) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      throw fb.FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter your email address.',
      );
    }

    await _auth.sendPasswordResetEmail(
      email: cleanEmail,
    );
  }
}