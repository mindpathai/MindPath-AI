import 'package:flutter/foundation.dart';

/// A signed-in user.
@immutable
class AppUser {
  const AppUser({required this.name, required this.email});

  final String name;
  final String email;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;
}

/// Base for every error an [AuthService] throws.
sealed class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class EmailAlreadyInUse extends AuthException {
  const EmailAlreadyInUse()
    : super('An account with this email already exists');
}

class UserNotFound extends AuthException {
  const UserNotFound() : super('No account found for this email');
}

class WrongPassword extends AuthException {
  const WrongPassword() : super('Incorrect password');
}

class WeakPassword extends AuthException {
  const WeakPassword(super.message);
}

/// The backend is rate-limiting this account or device.
class TooManyAttempts extends AuthException {
  const TooManyAttempts()
    : super('Too many attempts. Please wait and try again');
}

/// The device could not reach the auth backend.
///
/// Deliberately not an [AuthException]: it says nothing about the
/// credentials, so it must never count toward the login lockout.
class AuthOffline implements Exception {
  const AuthOffline();

  static const String message =
      'You seem to be offline. Check your connection and try again.';

  @override
  String toString() => 'AuthOffline: $message';
}

/// Authentication contract. Screens depend only on this, so a Firebase
/// implementation can replace the mock without UI changes.
///
/// Notifies listeners whenever [currentUser] changes.
abstract class AuthService extends ChangeNotifier {
  AppUser? get currentUser;

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> signIn({required String email, required String password});

  Future<void> signOut();

  /// Completes normally whether or not the account exists.
  Future<void> resetPassword(String email);
}
