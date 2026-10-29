import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/app_card.dart';
import 'package:mindpath_ai/widgets/layout.dart';

/// Placeholder for crisis and safety resources.
class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ContentWidth(
            child: ScreenScroll(
              children: [
                ScreenTopBar(
                  title: 'Safety',
                  onBack: canPop ? () => Navigator.of(context).pop() : null,
                ),
                const SizedBox(height: AppSpace.s18),
                Text('You are not alone', style: AppTypography.title),
                const SizedBox(height: AppSpace.s8),
                Text(
                  'Help is available right now.',
                  style: AppTypography.lead.copyWith(color: AppColors.ink2),
                ),
                const SizedBox(height: AppSpace.s18),
                AppCard(
                  child: Text(
                    'If you are in immediate danger or thinking about harming '
                    'yourself, please contact your local emergency services '
                    'or someone you trust right now.',
                    style: AppTypography.lead,
                  ),
                ),
                const SizedBox(height: AppSpace.s14),
                const NoteText(
                  'Helplines and safety planning tools are coming soon.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
