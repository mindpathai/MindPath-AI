import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/screens/assessment_screen.dart';
import 'package:mindpath_ai/screens/chat_screen.dart';
import 'package:mindpath_ai/screens/forgot_password_screen.dart';
import 'package:mindpath_ai/screens/history_screen.dart';
import 'package:mindpath_ai/screens/home_screen.dart';
import 'package:mindpath_ai/screens/home_shell.dart';
import 'package:mindpath_ai/screens/login_screen.dart';
import 'package:mindpath_ai/screens/profile_screen.dart';
import 'package:mindpath_ai/screens/progress_screen.dart';
import 'package:mindpath_ai/screens/register_screen.dart';
import 'package:mindpath_ai/screens/report_screen.dart';
import 'package:mindpath_ai/screens/safety_screen.dart';
import 'package:mindpath_ai/screens/therapy_screen.dart';
import 'package:mindpath_ai/screens/welcome_screen.dart';
import 'package:mindpath_ai/services/auth_service.dart';

/// Route paths used across the app.
class AppRoutes {
  AppRoutes._();

  /// Entry point; redirects straight to Home or Welcome.
  static const String root = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String assessment = '/assessment';
  static const String therapy = '/therapy';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String report = '/report';
  static const String history = '/history';
  static const String chat = '/chat';
  static const String safety = '/safety';

  /// Reachable without signing in.
  static const Set<String> public = {
    root,
    welcome,
    login,
    register,
    forgotPassword,
    safety,
  };
}

/// Builds one bottom-nav branch with a single route.
StatefulShellBranch _tab(String path, GoRouterWidgetBuilder builder) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: builder)],
  );
}

/// Signed-out users are sent to Welcome from any non-public route.
GoRouter createRouter(AuthService auth) => GoRouter(
  initialLocation: AppRoutes.root,
  refreshListenable: auth,
  redirect: (context, state) {
    final signedIn = auth.currentUser != null;
    if (!signedIn && !AppRoutes.public.contains(state.matchedLocation)) {
      return AppRoutes.welcome;
    }
    return null;
  },
  routes: [
    // No Flutter splash: Android's launch window covers start-up, and the
    // signed-in user is known as soon as the auth service exists.
    GoRoute(
      path: AppRoutes.root,
      redirect: (context, state) =>
          auth.currentUser != null ? AppRoutes.home : AppRoutes.welcome,
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.safety,
      builder: (context, state) => const SafetyScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => HomeShell(shell: shell),
      branches: [
        _tab(AppRoutes.home, (context, state) => const HomeScreen()),
        _tab(
          AppRoutes.assessment,
          (context, state) => const AssessmentScreen(),
        ),
        _tab(AppRoutes.therapy, (context, state) => const TherapyScreen()),
        _tab(AppRoutes.progress, (context, state) => const ProgressScreen()),
        _tab(AppRoutes.profile, (context, state) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: AppRoutes.report,
      builder: (context, state) => const ReportScreen(),
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatScreen(),
    ),
  ],
);
