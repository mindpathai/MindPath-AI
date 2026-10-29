import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpath_ai/app.dart';
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

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('System Back on the Check-in tab returns to Home', (
    tester,
  ) async {
    final closed = await _openHome(tester);
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    expect(find.text('Keep or let go'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Start your check-in'), findsOneWidget);
    expect(closed, isEmpty);
  });

  testWidgets('System Back on Home leaves the app', (tester) async {
    final closed = await _openHome(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(closed, isNotEmpty);
  });

  testWidgets('System Back on a pushed screen pops it', (tester) async {
    final closed = await _openHome(tester);
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Let it go'));
    await tester.pumpAndSettle();
    expect(find.text('Your fingerprint'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Keep or let go'), findsOneWidget);
    expect(closed, isEmpty);
  });
}
