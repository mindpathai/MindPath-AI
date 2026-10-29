import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpath_ai/app.dart';
import 'package:mindpath_ai/screens/forgot_password_screen.dart';
import 'package:mindpath_ai/screens/login_screen.dart';
import 'package:mindpath_ai/services/mock_auth_service.dart';

const _demo = MockAuthService.demoEmail;

/// Field labels render upper-cased, as in the design.
Finder _field(String label) =>
    find.widgetWithText(TextFormField, label.toUpperCase());

Finder _button(String label) => find.widgetWithText(FilledButton, label);

/// Scrolls [finder] into view (building it if the list is lazy), then taps.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    100,
    scrollable: find.byType(Scrollable).first,
  );
  // scrollUntilVisible only scrolls one way; settle the target on screen.
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

Future<void> _enter(WidgetTester tester, String label, String text) async {
  await tester.scrollUntilVisible(
    _field(label),
    100,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.enterText(_field(label), text);
}

Future<void> _openLogin(WidgetTester tester) async {
  await tester.pumpWidget(
    MindPathApp(authService: MockAuthService(delay: Duration.zero)),
  );
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
  await _tap(tester, _button('Log in'));
  await tester.pumpAndSettle();
}

void main() {
  // No network in tests; fall back to the default font.
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Signed out, the app opens straight on Welcome', (tester) async {
    await tester.pumpWidget(
      MindPathApp(authService: MockAuthService(delay: Duration.zero)),
    );
    await tester.pump();
    expect(find.text('MindPath'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('Signed in, the app opens straight on Home', (tester) async {
    final auth = MockAuthService(delay: Duration.zero);
    await tester.runAsync(
      () => auth.signIn(email: _demo, password: MockAuthService.demoPassword),
    );
    await tester.pumpWidget(MindPathApp(authService: auth));
    await tester.pump();
    expect(find.text('Start your check-in'), findsOneWidget);
  });

  testWidgets('Login reaches the dashboard', (tester) async {
    await _openLogin(tester);
    await _enter(tester, 'Email', _demo);
    await _enter(tester, 'Password', MockAuthService.demoPassword);
    await _tap(tester, _button('Log in'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Demo'), findsOneWidget);
    expect(find.text('Start your check-in'), findsOneWidget);
  });

  testWidgets('Login failures are generic and lock after 5', (tester) async {
    await _openLogin(tester);
    await _enter(tester, 'Email', 'nobody@example.com');
    await _enter(tester, 'Password', 'Wrong#123');

    for (var i = 0; i < 5; i++) {
      await _tap(tester, _button('Log in'));
      await tester.pumpAndSettle();
      if (i < 4) expect(find.text(LoginScreen.failedMessage), findsOneWidget);
    }

    expect(find.text('Try again in 30s'), findsOneWidget);
    final locked = tester.widget<FilledButton>(_button('Try again in 30s'));
    expect(locked.onPressed, isNull);

    // Expiry is covered by the LoginThrottle unit test; dispose the ticker.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Forgot password always shows the same reply', (tester) async {
    await _openLogin(tester);
    await _tap(tester, find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await _enter(tester, 'Email', 'nobody@example.com');
    await _tap(tester, _button('Send reset link'));
    await tester.pumpAndSettle();

    expect(find.text(ForgotPasswordScreen.sentMessage), findsOneWidget);
  });

  testWidgets('Register stays disabled until valid and consented', (
    tester,
  ) async {
    await _openLogin(tester);
    await _tap(tester, find.text('New here? Create account'));
    await tester.pumpAndSettle();

    await _enter(tester, 'Full name', 'Ali Khan');
    await _enter(tester, 'Email', 'ali@example.com');
    await _enter(tester, 'Password', 'Blue!River9');
    await _enter(tester, 'Confirm password', 'Blue!River9');
    await tester.pump();

    FilledButton submit() => tester.widget(_button('Create account'));
    await tester.scrollUntilVisible(
      _button('Create account'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(submit().onPressed, isNull);

    await _tap(tester, find.text('I am 18 or older'));
    await _tap(tester, find.textContaining('not a medical diagnosis').last);
    await tester.pump();
    expect(submit().onPressed, isNotNull);

    await _tap(tester, _button('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Start your check-in'), findsOneWidget);
  });
}
