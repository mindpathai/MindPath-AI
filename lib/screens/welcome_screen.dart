import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/routes/app_router.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/app_buttons.dart';
import 'package:mindpath_ai/widgets/layout.dart';

/// Entry point with Login and Create account (navigation only).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ContentWidth(
            child: ScreenScroll(
              footer: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpace.s30),
                  PillButton.submit(
                    label: 'Log in',
                    onPressed: () => context.push(AppRoutes.login),
                  ),
                  const SizedBox(height: AppSpace.s11),
                  PillButton(
                    label: 'Create account',
                    style: PillStyle.ghost,
                    expand: true,
                    large: true,
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.s15),
                    onPressed: () => context.push(AppRoutes.register),
                  ),
                  const SizedBox(height: AppSpace.s24),
                  const NoteText(kNoDiagnosisNote),
                  const SizedBox(height: AppSpace.s26),
                ],
              ),
              children: const [
                SizedBox(height: AppSpace.s38),
                BrandHeader(
                  caption:
                      'A quiet first step for obsessive thoughts and '
                      'difficulty letting go.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
