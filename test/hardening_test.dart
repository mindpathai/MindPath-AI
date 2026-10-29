import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpath_ai/app.dart';
import 'package:mindpath_ai/screens/forgot_password_screen.dart';
import 'package:mindpath_ai/screens/login_screen.dart';
import 'package:mindpath_ai/services/auth_service.dart';
import 'package:mindpath_ai/services/mock_auth_service.dart';

Finder _field(String label) =>
    find.widgetWithText(TextFormField, label.toUpperCase());

Finder _button(String label) => find.widgetWithText(FilledButton, label);

/// Opens [route] on a phone-sized screen. Signs in first when [signedIn].
Future<MockAuthService> _open(
  WidgetTester tester,
  String route, {
  bool signedIn = false,
  bool offline = false,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 812 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final auth = MockAuthService(delay: Duration.zero);
  if (signedIn) {
    await tester.runAsync(
      () => auth.signIn(
        email: MockAuthService.demoEmail,
        password: MockAuthService.demoPassword,
      ),
    );
  }
  auth.offline = offline;
  await tester.pumpWidget(MindPathApp(authService: auth));
  await tester.runAsync(GoogleFonts.pendingFonts);
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
  await tester.pumpAndSettle();
  return auth;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Offline', () {
    testWidgets('login says offline and never locks the account', (
      tester,
    ) async {
      await _open(tester, '/login', offline: true);
      await tester.enterText(_field('Email'), MockAuthService.demoEmail);
      await tester.enterText(_field('Password'), MockAuthService.demoPassword);
      for (var i = 0; i < 6; i++) {
        await _tap(tester, _button('Log in'));
      }
      expect(find.text(AuthOffline.message), findsOneWidget);
      expect(find.text(LoginScreen.failedMessage), findsNothing);
      // Six offline attempts and the button is still usable.
      expect(_button('Log in'), findsOneWidget);
      expect(find.textContaining('Try again in'), findsNothing);
    });

    testWidgets('reset does not claim an email was sent', (tester) async {
      await _open(tester, '/forgot-password', offline: true);
      await tester.enterText(_field('Email'), 'ali@example.com');
      await _tap(tester, _button('Send reset link'));
      expect(find.text(AuthOffline.message), findsOneWidget);
      expect(find.text(ForgotPasswordScreen.sentMessage), findsNothing);
    });

    testWidgets('reset works again once back online', (tester) async {
      final auth = await _open(tester, '/forgot-password', offline: true);
      await tester.enterText(_field('Email'), 'ali@example.com');
      await _tap(tester, _button('Send reset link'));
      auth.offline = false;
      await _tap(tester, _button('Send reset link'));
      expect(find.text(ForgotPasswordScreen.sentMessage), findsOneWidget);
    });

    testWidgets('register says offline', (tester) async {
      await _open(tester, '/register', offline: true);
      await tester.enterText(_field('Full name'), 'Ali Khan');
      await tester.enterText(_field('Email'), 'ali@example.com');
      await tester.enterText(_field('Password'), 'Blue!River9');
      await tester.enterText(_field('Confirm password'), 'Blue!River9');
      await _tap(tester, find.text('I am 18 or older'));
      await _tap(tester, find.textContaining('not a medical diagnosis').last);
      await _tap(tester, _button('Create account'));
      expect(find.text(AuthOffline.message), findsOneWidget);
    });
  });

  group('Touch targets and labels (Android guidelines)', () {
    for (final (route, signedIn) in [
      ('/welcome', false),
      ('/login', false),
      ('/register', false),
      ('/forgot-password', false),
      ('/safety', false),
      ('/home', true),
      ('/assessment', true),
      ('/report', true),
    ]) {
      testWidgets(route, (tester) async {
        final handle = tester.ensureSemantics();
        await _open(tester, route, signedIn: signedIn);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }
  });

  testWidgets('Difficulty scale reads as a radio group with meaning', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _open(tester, '/assessment', signedIn: true);
    expect(
      tester.getSemantics(find.bySemanticsLabel('0 of 4, not at all hard')),
      isSemantics(isInMutuallyExclusiveGroup: true, hasCheckedState: true),
    );
    expect(find.bySemanticsLabel('4 of 4, extremely hard'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('3 of 4')),
      isSemantics(
        isInMutuallyExclusiveGroup: true,
        hasCheckedState: true,
        isChecked: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('Reduce Motion removes press and selection scaling', (
    tester,
  ) async {
    await _open(tester, '/home', signedIn: true);
    expect(find.byType(AnimatedScale), findsWidgets);

    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpAndSettle();
    // Only the mood strip keeps its AnimatedScale, set to an instant change.
    final scales = tester.widgetList<AnimatedScale>(find.byType(AnimatedScale));
    expect(scales.every((s) => s.duration == Duration.zero), isTrue);
  });
}
