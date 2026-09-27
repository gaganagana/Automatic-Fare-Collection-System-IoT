import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/models.dart';

/// Wraps Firebase Authentication (identity / login) and a Firestore
/// "users" collection (role + authorization data).
///
/// AUTHENTICATION = Firebase Auth verifies the email/password. Firebase
/// hashes and stores passwords on Google's servers with scrypt — this app
/// never sees or stores a raw password anywhere.
///
/// AUTHORIZATION = the Firestore document at users/{uid} holds a `role`
/// field ("admin" or "passenger") and, for passengers, a `linkedUid`
/// pointing at their RFID card. AppState reads this document right after
/// login and uses it to decide which screen (and which data) the person
/// is allowed to see.
class AuthService {
  static final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fires whenever Firebase's local session changes (login, logout, or
  /// automatic session restore on app start — this is what gives you
  /// "stay logged in after closing the app" for free).
  static Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  static fb.User? get currentFirebaseUser => _auth.currentUser;

  /// Sign in an existing account. Throws fb.FirebaseAuthException on
  /// wrong password / unknown email / etc — catch it in the UI.
  static Future<UserAccount> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final profile = await _loadProfile(cred.user!);
    if (profile == null) {
      throw fb.FirebaseAuthException(
        code: 'no-profile',
        message: 'This account has no role assigned in Firestore (users/${cred.user!.uid}).',
      );
    }
    return profile;
  }

  /// Creates a brand-new Firebase Auth account AND its Firestore profile
  /// document in one go. Used by the in-app "Register" screen for new
  /// passengers. Admin accounts are created once, manually, in the
  /// Firebase console (see SETUP_GUIDE.md section 6) — the app itself
  /// does not expose an "become admin" option.
  static Future<UserAccount> registerPassenger({
    required String email,
    required String password,
    required String username,
    required String linkedUid,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _db.collection('users').doc(cred.user!.uid).set({
      'username': username,
      'email': email,
      'role': 'passenger',
      'linkedUid': linkedUid.toUpperCase(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return UserAccount(
      uid: cred.user!.uid,
      username: username,
      role: UserRole.passenger,
      email: email,
      linkedUid: linkedUid.toUpperCase(),
    );
  }

  static Future<UserAccount?> _loadProfile(fb.User firebaseUser) async {
    final doc = await _db.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UserAccount(
      uid: firebaseUser.uid,
      username: data['username'] ?? firebaseUser.email!.split('@').first,
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.passenger,
      email: firebaseUser.email ?? data['email'] ?? '',
      linkedUid: data['linkedUid'],
    );
  }

  /// Used on app start when Firebase reports an existing session, so we
  /// can rebuild the UserAccount (with role) without asking for a
  /// password again.
  static Future<UserAccount?> loadProfileForCurrentUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return _loadProfile(u);
  }

  static Future<void> signOut() => _auth.signOut();

  static Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}
