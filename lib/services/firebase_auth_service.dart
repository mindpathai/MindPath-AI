import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mindpath_ai/services/auth_service.dart';
import 'package:mindpath_ai/services/validators.dart';

/// Version of the consent wording on the Register screen. Bump it whenever
/// that wording changes, so each stored record shows which text was agreed to.
const String kConsentVersion = '2026-10-v1';

/// [AuthService] backed by Firebase Authentication. Each user's profile and
/// consent record live in Firestore at `users/{uid}`.
///
/// Credential failures are mapped to [AuthException]s so the Login screen's
/// lockout counts them. Network and other unexpected errors are rethrown
/// unchanged and are not counted.
class FirebaseAuthService extends AuthService {
  FirebaseAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance {
    _current = _toAppUser(_auth.currentUser);
    _sub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  late final StreamSubscription<User?> _sub;
  AppUser? _current;

  /// True while sign-up is still writing the profile, so a half-made
  /// account is never reported as signed in.
  bool _signingUp = false;

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = normalizeName(name);
    final key = normalizeEmail(email);
    final weak = validatePassword(password, name: cleanName, email: key);
    if (weak != null) throw WeakPassword(weak);

    _signingUp = true;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: key,
        password: password,
      );
      final user = credential.user!;
      try {
        await user.updateDisplayName(cleanName);
        await _userDoc(user.uid).set({
          'name': cleanName,
          'email': key,
          'createdAt': FieldValue.serverTimestamp(),
          // signUp is only reachable once both Register consent boxes are
          // ticked, so reaching here means both were agreed to.
          'consent': {
            'version': kConsentVersion,
            'acceptedAt': FieldValue.serverTimestamp(),
            'isAdult': true,
            'understandsScreeningNotDiagnosis': true,
          },
        });
      } catch (e) {
        // No account may exist without its consent record.
        try {
          await user.delete();
        } catch (_) {}
        if (e is FirebaseException && e.code == 'unavailable') {
          throw const AuthOffline();
        }
        rethrow;
      }

      final appUser = AppUser(name: cleanName, email: key);
      _setCurrent(appUser);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } finally {
      _signingUp = false;
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizeEmail(email),
        password: password,
      );
      final appUser = _toAppUser(credential.user)!;
      _setCurrent(appUser);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _setCurrent(null);
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: normalizeEmail(email));
    } on FirebaseAuthException catch (e) {
      // Same outcome whether or not the account exists.
      if (e.code == 'user-not-found' || e.code == 'invalid-email') return;
      throw _mapError(e);
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Picks up restored sessions and sign-outs from outside this service.
  void _onAuthChanged(User? user) {
    if (_signingUp) return;
    final next = _toAppUser(user);
    if (next?.email == _current?.email && next?.name == _current?.name) return;
    _setCurrent(next);
  }

  void _setCurrent(AppUser? user) {
    _current = user;
    notifyListeners();
  }

  static AppUser? _toAppUser(User? user) => user == null
      ? null
      : AppUser(name: user.displayName ?? '', email: user.email ?? '');

  /// Wrong email and wrong password map to the same kinds the mock throws,
  /// so the screens stay generic and never reveal which accounts exist.
  static Object _mapError(FirebaseAuthException e) => switch (e.code) {
    'email-already-in-use' => const EmailAlreadyInUse(),
    'weak-password' => WeakPassword(e.message ?? 'Choose a stronger password'),
    'user-not-found' || 'invalid-email' => const UserNotFound(),
    'wrong-password' ||
    'invalid-credential' ||
    'user-disabled' => const WrongPassword(),
    'too-many-requests' => const TooManyAttempts(),
    'network-request-failed' => const AuthOffline(),
    _ => e,
  };
}
