import 'package:flutter_test/flutter_test.dart';

import 'package:mindpath_ai/services/auth_service.dart';
import 'package:mindpath_ai/services/login_throttle.dart';
import 'package:mindpath_ai/services/mock_auth_service.dart';

void main() {
  group('MockAuthService', () {
    late MockAuthService auth;

    setUp(() => auth = MockAuthService(delay: Duration.zero));

    test('signs up, signs out and signs back in', () async {
      final user = await auth.signUp(
        name: ' Ali Khan ',
        email: 'Ali@Example.com',
        password: 'Blue!River9',
      );
      expect(user.email, 'ali@example.com');
      expect(user.firstName, 'Ali');
      expect(auth.currentUser, user);

      await auth.signOut();
      expect(auth.currentUser, isNull);

      await auth.signIn(email: 'ali@example.com ', password: 'Blue!River9');
      expect(auth.currentUser?.name, 'Ali Khan');
    });

    test('throws typed errors', () async {
      await expectLater(
        auth.signUp(
          name: 'Someone',
          email: MockAuthService.demoEmail,
          password: 'Blue!River9',
        ),
        throwsA(isA<EmailAlreadyInUse>()),
      );
      await expectLater(
        auth.signUp(name: 'Someone', email: 'new@x.com', password: 'short'),
        throwsA(isA<WeakPassword>()),
      );
      await expectLater(
        auth.signIn(email: 'nobody@x.com', password: 'Blue!River9'),
        throwsA(isA<UserNotFound>()),
      );
      await expectLater(
        auth.signIn(email: MockAuthService.demoEmail, password: 'Wrong#123'),
        throwsA(isA<WrongPassword>()),
      );
    });

    test('resetPassword completes for unknown emails', () async {
      await auth.resetPassword('nobody@x.com');
    });

    test('notifies listeners on sign in', () async {
      var calls = 0;
      auth.addListener(() => calls++);
      await auth.signIn(
        email: MockAuthService.demoEmail,
        password: MockAuthService.demoPassword,
      );
      expect(calls, 1);
    });
  });

  group('LoginThrottle', () {
    test('locks after 5 failures and unlocks after 30 seconds', () {
      var now = DateTime(2026);
      final throttle = LoginThrottle(clock: () => now);

      for (var i = 0; i < 4; i++) {
        throttle.recordFailure();
      }
      expect(throttle.isLocked, isFalse);

      throttle.recordFailure();
      expect(throttle.isLocked, isTrue);
      expect(throttle.remaining, const Duration(seconds: 30));

      now = now.add(const Duration(seconds: 29));
      expect(throttle.isLocked, isTrue);

      now = now.add(const Duration(seconds: 1));
      expect(throttle.isLocked, isFalse);
      expect(throttle.failures, 0);
    });
  });
}
