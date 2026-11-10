import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/app_card.dart';
import 'package:mindpath_ai/widgets/layout.dart';

/// Crisis and safety numbers, reachable without signing in (SOS chip).
class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  /// Pakistan numbers. Check them again before each release.
  static const List<({String name, String number, String note})> helplines = [
    (
      name: 'Rescue (emergency)',
      number: '1122',
      note: 'Ambulance and emergency help',
    ),
    (name: 'Police', number: '15', note: 'If you or someone else is in danger'),
    (name: 'Edhi ambulance', number: '115', note: 'Ambulance, day and night'),
    (
      name: 'Umang mental health helpline',
      number: '0311 7786264',
      note: 'Talk to a trained listener',
    ),
  ];

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
                  title: 'Get help',
                  onBack: canPop ? () => Navigator.of(context).pop() : null,
                ),
                const SizedBox(height: AppSpace.s18),
                Semantics(
                  header: true,
                  child: Text('You are not alone', style: AppTypography.title),
                ),
                const SizedBox(height: AppSpace.s8),
                Text(
                  'Help is available right now.',
                  style: AppTypography.lead.copyWith(color: AppColors.ink2),
                ),
                const SizedBox(height: AppSpace.s18),
                AppCard(
                  child: Text(
                    'If you are in danger or thinking about harming '
                    'yourself, please call one of these numbers or talk to '
                    'someone you trust right now.',
                    style: AppTypography.lead,
                  ),
                ),
                const SizedBox(height: AppSpace.s14),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.s16,
                    vertical: AppSpace.s6,
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < helplines.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: AppSizes.hairline,
                            thickness: AppSizes.hairline,
                            color: AppColors.line2,
                          ),
                        _HelplineRow(
                          name: helplines[i].name,
                          number: helplines[i].number,
                          note: helplines[i].note,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.s14),
                const NoteText(
                  'MindPath cannot answer emergencies. If you cannot call, '
                  'ask someone near you for help.',
                ),
                const SizedBox(height: AppSpace.s26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HelplineRow extends StatelessWidget {
  const _HelplineRow({
    required this.name,
    required this.number,
    required this.note,
  });

  final String name;
  final String number;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$name, $number. $note',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.bodySemi),
                  const SizedBox(height: AppSpace.s2),
                  Text(note, style: AppTypography.caption),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s12),
            SelectableText(
              number,
              style: AppTypography.strong.copyWith(color: AppColors.pine),
            ),
          ],
        ),
      ),
    );
  }
}
