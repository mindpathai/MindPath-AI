import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpath_ai/app.dart';
import 'package:mindpath_ai/screens/login_screen.dart';
import 'package:mindpath_ai/services/mock_auth_service.dart';

/// Pumps the app signed in, on Home. Records whether the app asked Android
/// to close (SystemNavigator.pop).
Future<List<String>> _openHome(WidgetTester tester) async {
  final closed = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'SystemNavigator.pop') closed.add(call.method);
      return null;
    },
  );
  final auth = MockAuthService(delay: Duration.zero);
  await tester.runAsync(
    () => auth.signIn(
      email: MockAuthService.demoEmail,
      password: MockAuthService.demoPassword,
    ),
  );
  await tester.pumpWidget(MindPathApp(authService: auth));
  // Let the bundled fonts finish loading before laying anything out again.
  await tester.runAsync(GoogleFonts.pendingFonts);
  await tester.pumpAndSettle();
  return closed;
}

const _newEmail = 'ali@example.com';
const _newPassword = 'Blue!River9';

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
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String label, String text) async {
  await tester.scrollUntilVisible(
    _field(label),
    100,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.enterText(_field(label), text);
  await tester.pump();
}

/// Registers a new account from Welcome and stops on the screen that follows.
Future<MockAuthService> _register(WidgetTester tester) async {
  final auth = MockAuthService(delay: Duration.zero);
  await tester.pumpWidget(MindPathApp(authService: auth));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Create account'));
  await tester.pumpAndSettle();

  await _enter(tester, 'Full name', 'Ali Khan');
  await _enter(tester, 'Email', _newEmail);
  await _enter(tester, 'Password', _newPassword);
  await _enter(tester, 'Type password again', _newPassword);
  await _tap(tester, find.text('I am 18 or older'));
  await _tap(tester, find.textContaining('not a medical diagnosis').last);
  await _tap(tester, _button('Create account'));
  return auth;
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Registering lands on Login, signed out, with a message', (
    tester,
  ) async {
    final auth = await _register(tester);

    expect(find.text(LoginScreen.accountCreatedMessage), findsOneWidget);
    expect(_button('Log in'), findsOneWidget);
    expect(find.text('Answer a few questions'), findsNothing);
    expect(auth.currentUser, isNull);
  });

  testWidgets('A new account reaches Home only by logging in', (tester) async {
    await _register(tester);

    await _enter(tester, 'Email', _newEmail);
    await _enter(tester, 'Password', _newPassword);
    await _tap(tester, _button('Log in'));

    expect(find.text('Answer a few questions'), findsOneWidget);
  });

  testWidgets('A failed login after registering replaces the message', (
    tester,
  ) async {
    await _register(tester);

    await _enter(tester, 'Email', _newEmail);
    await _enter(tester, 'Password', 'Not!ThePass1');
    await _tap(tester, _button('Log in'));

    expect(find.text(LoginScreen.failedMessage), findsOneWidget);
    expect(find.text(LoginScreen.accountCreatedMessage), findsNothing);
  });

  testWidgets('System Back from Login after registering returns to Welcome', (
    tester,
  ) async {
    await _register(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text(LoginScreen.accountCreatedMessage), findsNothing);
  });

  testWidgets('System Back on the Questions tab returns to Home', (
    tester,
  ) async {
    final closed = await _openHome(tester);
    await _tap(tester, find.text('Start'));
    expect(find.text('Keep or let go'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Answer a few questions'), findsOneWidget);
    expect(closed, isEmpty);
  });

  testWidgets('The bottom bar shows only what is built', (tester) async {
    await _openHome(tester);
    expect(find.text('Questions'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Therapy'), findsNothing);
    expect(find.text('Progress'), findsNothing);
  });

  testWidgets('Each visible tab opens its own screen', (tester) async {
    await _openHome(tester);
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    expect(find.text('Log out'), findsOneWidget);

    await tester.tap(find.text('Questions'));
    await tester.pumpAndSettle();
    expect(find.text('Keep or let go'), findsOneWidget);
  });

  for (final route in ['/therapy', '/progress', '/history', '/chat']) {
    testWidgets('A direct link to $route lands on Home', (tester) async {
      await _openHome(tester);
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go(route);
      await tester.pumpAndSettle();
      expect(find.text('Answer a few questions'), findsOneWidget);
    });
  }

  testWidgets('System Back on Home leaves the app', (tester) async {
    final closed = await _openHome(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(closed, isNotEmpty);
  });

  testWidgets('System Back on a pushed screen pops it', (tester) async {
    final closed = await _openHome(tester);
    await _tap(tester, find.text('Start'));
    await _tap(tester, find.text('Let it go'));
    expect(find.text('Your results'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Keep or let go'), findsOneWidget);
    expect(closed, isEmpty);
  });
}
