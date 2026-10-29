import 'package:mindpath_ai/services/auth_service.dart';
import 'package:mindpath_ai/services/validators.dart';

/// In-memory [AuthService] for tests and offline development. Data is lost
/// on restart. The app uses FirebaseAuthService unless this is passed in.
class MockAuthService extends AuthService {
  MockAuthService({
    this.delay = const Duration(seconds: 1),
    bool seedDemoUser = true,
    this.offline = false,
  }) {
    if (seedDemoUser) {
      _users[demoEmail] = (
        user: const AppUser(name: 'Demo User', email: demoEmail),
        password: demoPassword,
      );
    }
  }

  /// Ready-made account for demos.
  static const String demoEmail = 'demo@mindpath.app';
  static const String demoPassword = 'Calm#Path24';

  final Duration delay;

  /// When true, every call fails with [AuthOffline], as with no network.
  bool offline;
  final Map<String, ({AppUser user, String password})> _users = {};
  AppUser? _current;

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    if (offline) throw const AuthOffline();
    final key = normalizeEmail(email);
    if (_users.containsKey(key)) throw const EmailAlreadyInUse();
    final weak = validatePassword(password, name: name, email: key);
    if (weak != null) throw WeakPassword(weak);

    final user = AppUser(name: normalizeName(name), email: key);
    _users[key] = (user: user, password: password);
    _setCurrent(user);
    return user;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    if (offline) throw const AuthOffline();
    final record = _users[normalizeEmail(email)];
    if (record == null) throw const UserNotFound();
    if (record.password != password) throw const WrongPassword();
    _setCurrent(record.user);
    return record.user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(delay);
    _setCurrent(null);
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future<void>.delayed(delay);
    if (offline) throw const AuthOffline();
    // A real backend would email a link here if the account exists.
  }

  void _setCurrent(AppUser? user) {
    _current = user;
    notifyListeners();
  }
}
