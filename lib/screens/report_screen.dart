import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/routes/app_router.dart';
import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/app_card.dart';
import 'package:mindpath_ai/widgets/arc_motifs.dart';
import 'package:mindpath_ai/widgets/dashboard_cards.dart';
import 'package:mindpath_ai/widgets/icon_badge.dart';
import 'package:mindpath_ai/widgets/layout.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

/// Placeholder version of the result screen ("Your fingerprint"), filled
/// with the design's sample data until the inference service exists.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  // Sample data from the design, outermost ring first.
  static const List<({String name, Tone tone, String level, double value})>
  _sample = [
    (name: 'Doubt & checking', tone: Tone.clay, level: 'High', value: 0.252),
    (name: 'Intrusive thoughts', tone: Tone.clay, level: 'High', value: 0.215),
    (
      name: 'Difficulty discarding',
      tone: Tone.pine,
      level: 'Medium',
      value: 0.176,
    ),
    (name: 'Order & symmetry', tone: Tone.pine, level: 'Medium', value: 0.147),
    (name: 'Clutter at home', tone: Tone.sage, level: 'Low', value: 0.125),
    (name: 'Overall distress', tone: Tone.sage, level: 'Low', value: 0.1),
  ];

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        pine: 0.06,
        clay: null,
        child: SafeArea(
          child: ContentWidth(
            child: ScreenScroll(
              children: [
                ScreenTopBar(
                  title: 'Your fingerprint',
                  onBack: () => _back(context),
                  trailing: IconButton(
                    tooltip: 'Share',
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerRight,
                    onPressed: () {}, // Placeholder until reports export.
                    icon: const LineIcon(
                      LineGlyphs.share,
                      color: AppColors.ink2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s3),
                Text('SAMPLE PREVIEW', style: AppTypography.eyebrow),
                const SizedBox(height: AppSpace.s8),
                Text(
                  'Checking and doubt\nstand out most.',
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpace.s18),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ArcChart(
                          bands: [
                            for (final s in _sample)
                              (value: s.value, color: s.tone.strong),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpace.s16),
                      for (var i = 0; i < _sample.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpace.s9),
                        _LegendRow(
                          name: _sample[i].name,
                          tone: _sample[i].tone,
                          level: _sample[i].level,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.s14),
                RowCard(
                  glyph: LineGlyphs.ladder,
                  tone: Tone.clay,
                  title: 'Suggested next: checking ladder',
                  caption: 'Start with the easiest step. 10 minutes.',
                  onTap: () {}, // Placeholder until Therapy exists.
                ),
                const SizedBox(height: AppSpace.s12),
                const NoteText(
                  'AI-assisted preliminary screening, based on your answers '
                  'and the OCI-R scoring bands. This is not a medical '
                  'diagnosis.',
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

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.name,
    required this.tone,
    required this.level,
  });

  final String name;
  final Tone tone;
  final String level;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizes.swatch,
          height: AppSizes.swatch,
          decoration: BoxDecoration(
            color: tone.strong,
            borderRadius: BorderRadius.circular(AppRadius.swatch),
          ),
        ),
        const SizedBox(width: AppSpace.s10),
        Expanded(
          child: Text(
            name,
            style: AppTypography.small.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: tone.soft,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s9,
              vertical: AppSpace.s3,
            ),
            // Ink, not tone.strong: clay and sage on their soft fills fall
            // below 4.5:1 at this size. The fill and swatch carry the tone.
            child: Text(
              level.toUpperCase(),
              style: AppTypography.levelTag.copyWith(color: AppColors.ink),
            ),
          ),
        ),
      ],
    );
  }
}
