import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/routes/app_router.dart';
import 'package:mindpath_ai/services/auth_scope.dart';
import 'package:mindpath_ai/services/auth_service.dart';
import 'package:mindpath_ai/services/login_throttle.dart';
import 'package:mindpath_ai/services/validators.dart';
import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/app_buttons.dart';
import 'package:mindpath_ai/widgets/app_card.dart';
import 'package:mindpath_ai/widgets/app_text_field.dart';
import 'package:mindpath_ai/widgets/form_message.dart';
import 'package:mindpath_ai/widgets/layout.dart';

/// Sign in. Failures never reveal whether the email has an account.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String failedMessage = 'Email or password is incorrect';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _throttle = LoginThrottle();

  bool _loading = false;
  String? _formError;
  Timer? _ticker;
  int _lockSeconds = 0;

  @override
  void dispose() {
    _ticker?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final seconds = (_throttle.remaining.inMilliseconds / 1000).ceil();
    if (seconds == 0) {
      _ticker?.cancel();
      _ticker = null;
    }
    setState(() {
      _lockSeconds = seconds;
      if (seconds == 0) _formError = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = AuthScope.read(context);
    setState(() {
      _loading = true;
      _formError = null;
    });

    try {
      await auth.signIn(email: _email.text, password: _password.text);
      _throttle.reset();
      if (mounted) context.go(AppRoutes.home);
      return;
    } on AuthException {
      _throttle.recordFailure();
      _formError = LoginScreen.failedMessage;
    } on AuthOffline {
      // Not a wrong password, so it does not count toward the lockout.
      _formError = AuthOffline.message;
    } catch (_) {
      _formError = 'Something went wrong. Please try again.';
    }

    if (!mounted) return;
    setState(() => _loading = false);
    if (_throttle.isLocked) _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final locked = _lockSeconds > 0;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ContentWidth(
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: ScreenScroll(
                  footer: const Padding(
                    padding: EdgeInsets.only(
                      top: AppSpace.s24,
                      bottom: AppSpace.s26,
                    ),
                    child: NoteText(kNoDiagnosisNote),
                  ),
                  children: [
                    const SizedBox(height: AppSpace.s38),
                    const BrandHeader(
                      caption:
                          'A quiet first step for obsessive thoughts and '
                          'difficulty letting go.',
                    ),
                    const SizedBox(height: AppSpace.s30),
                    AppCard(
                      // No bottom padding: the 48px link row's own space
                      // already matches the 14px at the top.
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.s14,
                        AppSpace.s14,
                        AppSpace.s14,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _email,
                            label: 'Email',
                            validator: validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                          ),
                          const SizedBox(height: AppSpace.s11),
                          AppTextField(
                            controller: _password,
                            label: 'Password',
                            validator: validateLoginPassword,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onSubmitted: (_) {
                              if (!locked && !_loading) _submit();
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: LinkButton(
                              onPressed: () =>
                                  context.push(AppRoutes.forgotPassword),
                              child: const Text('Forgot password?'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Fixed text, so the live region is announced once; the
                    // button carries the countdown.
                    FormMessage(
                      locked
                          ? 'Too many attempts. Please wait '
                                '${_throttle.lockDuration.inSeconds} seconds '
                                'and try again.'
                          : _formError,
                    ),
                    const SizedBox(height: AppSpace.s18),
                    PillButton.submit(
                      label: locked
                          ? 'Try again in ${_lockSeconds}s'
                          : 'Log in',
                      loading: _loading,
                      onPressed: locked ? null : _submit,
                    ),
                    Center(
                      child: LinkButton(
                        onPressed: () =>
                            context.pushReplacement(AppRoutes.register),
                        child: const Text.rich(
                          TextSpan(
                            text: 'New here? ',
                            style: TextStyle(
                              color: AppColors.ink2,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: 'Create account',
                                style: TextStyle(
                                  color: AppColors.pine,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
