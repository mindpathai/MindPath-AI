import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/routes/app_router.dart';
import 'package:mindpath_ai/services/auth_scope.dart';
import 'package:mindpath_ai/services/auth_service.dart';
import 'package:mindpath_ai/services/validators.dart';
import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/app_buttons.dart';
import 'package:mindpath_ai/widgets/app_card.dart';
import 'package:mindpath_ai/widgets/app_text_field.dart';
import 'package:mindpath_ai/widgets/form_message.dart';
import 'package:mindpath_ai/widgets/layout.dart';

/// Requests a reset link. The reply is identical whether or not the
/// account exists.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String sentMessage =
      'If an account exists for that email, you will receive a link to '
      'reset your password shortly.';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _formError;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = AuthScope.read(context);
    setState(() {
      _loading = true;
      _formError = null;
    });
    String? error;
    try {
      await auth.resetPassword(_email.text);
    } on AuthOffline {
      // Nothing was sent, so do not claim it was. Says nothing about
      // whether the account exists.
      error = AuthOffline.message;
    } catch (_) {
      // Same reply either way, so nothing leaks.
    }
    if (mounted) {
      setState(() {
        _loading = false;
        _formError = error;
        _sent = error == null;
      });
    }
  }

  void _backToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topBar = ScreenTopBar(title: 'Reset password', onBack: _backToLogin);

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ContentWidth(
            child: AnimatedSwitcher(
              duration: AppMotion.duration,
              switchInCurve: AppMotion.curve,
              switchOutCurve: AppMotion.curve,
              child: _sent
                  ? ScreenScroll(
                      key: const ValueKey('sent'),
                      children: [
                        topBar,
                        const SizedBox(height: AppSpace.s18),
                        const _Intro(
                          title: 'Check your email',
                          caption: ForgotPasswordScreen.sentMessage,
                        ),
                        const SizedBox(height: AppSpace.s30),
                        PillButton.submit(
                          label: 'Back to log in',
                          onPressed: _backToLogin,
                        ),
                      ],
                    )
                  : Form(
                      key: _formKey,
                      child: ScreenScroll(
                        children: [
                          topBar,
                          const SizedBox(height: AppSpace.s18),
                          const _Intro(
                            title: 'Reset your password',
                            caption:
                                'Enter the email you signed up with and we '
                                'will send you a reset link.',
                          ),
                          const SizedBox(height: AppSpace.s30),
                          AppCard(
                            padding: const EdgeInsets.all(AppSpace.s14),
                            child: AppTextField(
                              controller: _email,
                              label: 'Email',
                              validator: validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              onSubmitted: (_) {
                                if (!_loading) _submit();
                              },
                            ),
                          ),
                          FormMessage(_formError),
                          const SizedBox(height: AppSpace.s18),
                          PillButton.submit(
                            label: 'Send reset link',
                            loading: _loading,
                            onPressed: _submit,
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

class _Intro extends StatelessWidget {
  const _Intro({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.title),
        const SizedBox(height: AppSpace.s8),
        Text(
          caption,
          style: AppTypography.lead.copyWith(color: AppColors.ink2),
        ),
      ],
    );
  }
}
