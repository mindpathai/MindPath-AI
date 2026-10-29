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
import 'package:mindpath_ai/widgets/password_feedback.dart';

/// Account creation with live password feedback and required consent.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _isAdult = false;
  bool _understands = false;
  bool _loading = false;
  String? _formError;

  // Server-side errors, kept only while the field still holds the same value.
  ({String value, String message})? _emailError;
  ({String value, String message})? _passwordError;

  List<TextEditingController> get _controllers => [
    _name,
    _email,
    _password,
    _confirm,
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_rebuild);
    }
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final e = _emailError;
    return validateEmail(v) ??
        (e != null && normalizeEmail(v ?? '') == e.value ? e.message : null);
  }

  String? _validatePassword(String? v) {
    final e = _passwordError;
    return validatePassword(v, name: _name.text, email: _email.text) ??
        (e != null && v == e.value ? e.message : null);
  }

  String? _validateConfirm(String? v) =>
      validateConfirmPassword(v, _password.text);

  bool get _canSubmit =>
      !_loading &&
      _isAdult &&
      _understands &&
      validateName(_name.text) == null &&
      _validateEmail(_email.text) == null &&
      _validatePassword(_password.text) == null &&
      _validateConfirm(_confirm.text) == null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = AuthScope.read(context);
    setState(() {
      _loading = true;
      _formError = null;
    });

    try {
      await auth.signUp(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      if (mounted) context.go(AppRoutes.home);
      return;
    } on EmailAlreadyInUse catch (e) {
      _emailError = (value: normalizeEmail(_email.text), message: e.message);
    } on WeakPassword catch (e) {
      _passwordError = (value: _password.text, message: e.message);
    } on AuthException catch (e) {
      _formError = e.message;
    } on AuthOffline {
      _formError = AuthOffline.message;
    } catch (_) {
      _formError = 'Something went wrong. Please try again.';
    }

    if (!mounted) return;
    setState(() => _loading = false);
    _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
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
                      title: 'Create account',
                      caption: 'It only takes a minute.',
                    ),
                    const SizedBox(height: AppSpace.s30),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpace.s14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _name,
                            label: 'Full name',
                            validator: validateName,
                            keyboardType: TextInputType.name,
                            autofillHints: const [AutofillHints.name],
                          ),
                          const SizedBox(height: AppSpace.s11),
                          AppTextField(
                            controller: _email,
                            label: 'Email',
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                          ),
                          const SizedBox(height: AppSpace.s11),
                          AppTextField(
                            controller: _password,
                            label: 'Password',
                            validator: _validatePassword,
                            isPassword: true,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                          const SizedBox(height: AppSpace.s12),
                          PasswordFeedback(password: _password.text),
                          const SizedBox(height: AppSpace.s11),
                          AppTextField(
                            controller: _confirm,
                            label: 'Confirm password',
                            validator: _validateConfirm,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.s24),
                    Text('BEFORE YOU CONTINUE', style: AppTypography.eyebrow),
                    const SizedBox(height: AppSpace.s9),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s14,
                        vertical: AppSpace.s6,
                      ),
                      child: Column(
                        children: [
                          _ConsentTile(
                            value: _isAdult,
                            label: 'I am 18 or older',
                            onChanged: (v) => setState(() => _isAdult = v),
                          ),
                          _ConsentTile(
                            value: _understands,
                            label:
                                'I understand this app provides preliminary '
                                'screening, not a medical diagnosis',
                            onChanged: (v) => setState(() => _understands = v),
                          ),
                        ],
                      ),
                    ),
                    FormMessage(_formError),
                    const SizedBox(height: AppSpace.s18),
                    PillButton.submit(
                      label: 'Create account',
                      loading: _loading,
                      onPressed: _canSubmit ? _submit : null,
                    ),
                    Center(
                      child: LinkButton(
                        onPressed: () =>
                            context.pushReplacement(AppRoutes.login),
                        child: const Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.ink2,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: 'Log in',
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

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTypography.small),
    );
  }
}
