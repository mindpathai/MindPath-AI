import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/routes/app_router.dart';
import 'package:mindpath_ai/services/auth_scope.dart';
import 'package:mindpath_ai/services/auth_service.dart';
import 'package:mindpath_ai/services/firebase_auth_service.dart';
import 'package:mindpath_ai/theme/app_theme.dart';

class MindPathApp extends StatefulWidget {
  /// Defaults to [FirebaseAuthService]. Tests pass a mock instead.
  const MindPathApp({super.key, this.authService});

  final AuthService? authService;

  @override
  State<MindPathApp> createState() => _MindPathAppState();
}

class _MindPathAppState extends State<MindPathApp> {
  late final AuthService _auth = widget.authService ?? FirebaseAuthService();
  late final GoRouter _router = createRouter(_auth);

  @override
  void dispose() {
    _router.dispose();
    if (widget.authService == null) _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      service: _auth,
      child: MaterialApp.router(
        title: 'MindPath AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
