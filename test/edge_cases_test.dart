import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpath_ai/app.dart';
import 'package:mindpath_ai/screens/login_screen.dart';
import 'package:mindpath_ai/screens/safety_screen.dart';
import 'package:mindpath_ai/services/auth_service.dart';
import 'package:mindpath_ai/services/mock_auth_service.dart';
import 'package:mindpath_ai/services/validators.dart';
import 'package:mindpath_ai/widgets/app_text_field.dart';

Finder _field(String label) =>
    find.widgetWithText(TextFormField, label.toUpperCase());

Finder _button(String label) => find.widgetWithText(FilledButton, label);

/// Counts sign-in and sign-up calls, to catch double submits.
class _CountingAuth extends MockAuthService {
  _CountingAuth() : super(delay: const Duration(milliseconds: 500));

  int signIns = 0;
  int signUps = 0;

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    signIns++;
    return super.signIn(email: email, password: password);
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    signUps++;
    return super.signUp(name: name, email: email, password: password);
  }
}

/// Opens [route] on a phone-sized screen. Signs in first when [signedIn].
Future<MockAuthService> _open(
  WidgetTester tester,
  String route, {
  bool signedIn = false,
  MockAuthService? auth,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 812 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final service = auth ?? MockAuthService(delay: Duration.zero);
  if (signedIn) {
    await tester.runAsync(
      () => service.signIn(
        email: MockAuthService.demoEmail,
        password: MockAuthService.demoPassword,
      ),
    );
  }
  await tester.pumpWidget(MindPathApp(authService: service));
  await tester.runAsync(GoogleFonts.pendingFonts);
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
  await tester.pumpAndSettle();
  return service;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _fillRegister(
  WidgetTester tester, {
  String name = 'Ali Khan',
  String? email = 'ali@example.com',
  String password = 'Blue!River9',
}) async {
  await tester.enterText(_field('Full name'), name);
  if (email != null) await tester.enterText(_field('Email'), email);
  await tester.enterText(_field('Password'), password);
  await tester.enterText(_field('Type password again'), password);
  await _tap(tester, find.text('I am 18 or older'));
  await _tap(tester, find.textContaining('not a medical diagnosis').last);
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Email check on Register', () {
    for (final email in ['abc@gmial.com', 'abc@gmail', 'notanemail']) {
      testWidgets('"$email" shows an error while typing and blocks submit', (
        tester,
      ) async {
        await _open(tester, '/register');
        // Focus stays in the email field: no blur, no submit.
        await tester.enterText(_field('Email'), email);
        await tester.pump(AppTextField.typingPause);
        await tester.pump();

        expect(
          find.textContaining(
            RegExp('valid email address|Did you mean abc@gmail.com'),
          ),
          findsOneWidget,
        );

        // Everything else valid and agreed: still blocked by the email.
        await _fillRegister(tester, email: null);
        final submit = tester.widget<FilledButton>(_button('Create account'));
        expect(submit.onPressed, isNull);
      });
    }

    testWidgets('no error flashes while the user is still typing', (
      tester,
    ) async {
      await _open(tester, '/register');
      await tester.enterText(_field('Email'), 'ali@');
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(kInvalidEmailMessage), findsNothing);
    });
  });

  group('Auth edge cases', () {
    testWidgets('a duplicate email shows under the email field', (
      tester,
    ) async {
      await _open(tester, '/register');
      await _fillRegister(tester, email: MockAuthService.demoEmail);
      await _tap(tester, _button('Create account'));
      expect(find.text(const EmailAlreadyInUse().message), findsOneWidget);
      expect(find.text(LoginScreen.accountCreatedMessage), findsNothing);
    });

    testWidgets('a pasted long name stops at the limit', (tester) async {
      await _open(tester, '/register');
      await tester.enterText(_field('Full name'), 'A' * 500);
      await tester.pump();
      final field = tester.widget<TextField>(
        find.descendant(
          of: _field('Full name'),
          matching: find.byType(TextField),
        ),
      );
      expect(field.controller!.text.length, kMaxNameLength);
    });

    testWidgets('spaces around the name and email are ignored', (tester) async {
      final auth = await _open(tester, '/register');
      await _fillRegister(
        tester,
        name: '  Ali    Khan  ',
        email: '  Ali@Example.com  ',
      );
      await _tap(tester, _button('Create account'));
      expect(find.text(LoginScreen.accountCreatedMessage), findsOneWidget);

      await tester.runAsync(
        () => auth.signIn(email: 'ali@example.com', password: 'Blue!River9'),
      );
      expect(auth.currentUser?.name, 'Ali Khan');
    });

    testWidgets('a rapid double tap on Log in signs in once', (tester) async {
      final auth = _CountingAuth();
      await _open(tester, '/login', auth: auth);
      await tester.enterText(_field('Email'), MockAuthService.demoEmail);
      await tester.enterText(_field('Password'), MockAuthService.demoPassword);
      await tester.ensureVisible(_button('Log in'));
      await tester.pumpAndSettle();

      await tester.tap(_button('Log in'));
      await tester.tap(_button('Log in'), warnIfMissed: false);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(auth.signIns, 1);
    });

    testWidgets('a rapid double tap on Create account signs up once', (
      tester,
    ) async {
      final auth = _CountingAuth();
      await _open(tester, '/register', auth: auth);
      await _fillRegister(tester);
      await tester.ensureVisible(_button('Create account'));
      await tester.pumpAndSettle();

      await tester.tap(_button('Create account'));
      await tester.tap(_button('Create account'), warnIfMissed: false);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(auth.signUps, 1);
      expect(find.text(LoginScreen.accountCreatedMessage), findsOneWidget);
    });

    testWidgets('a signed-in user who opens Login is sent Home', (
      tester,
    ) async {
      await _open(tester, '/login', signedIn: true);
      expect(find.text('Answer a few questions'), findsOneWidget);
    });
  });

  group('Screens reachable today are complete', () {
    testWidgets('Safety lists every helpline', (tester) async {
      await _open(tester, '/safety');
      for (final line in SafetyScreen.helplines) {
        expect(find.text(line.number), findsOneWidget, reason: line.name);
      }
      expect(find.textContaining('coming soon'), findsNothing);
    });

    testWidgets('You shows the account and logs out to Welcome', (
      tester,
    ) async {
      await _open(tester, '/profile', signedIn: true);
      expect(find.text('Demo User'), findsOneWidget);
      expect(find.text(MockAuthService.demoEmail), findsOneWidget);
      expect(find.text('Coming soon'), findsNothing);

      await _tap(tester, find.text('Log out'));
      expect(_button('Log in'), findsOneWidget);
    });
  });
}
