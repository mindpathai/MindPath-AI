import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/routes/app_router.dart';
import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/app_buttons.dart';
import 'package:mindpath_ai/widgets/app_card.dart';
import 'package:mindpath_ai/widgets/layout.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';
import 'package:mindpath_ai/widgets/press_scale.dart';
import 'package:mindpath_ai/widgets/task_progress.dart';

/// Check-in tab. Placeholder version of the "Keep or let go" sorting task:
/// one sample item, no scoring yet.
class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _difficulty = 3;

  // Placeholder: both choices open the sample result until the task
  // engine exists.
  void _choose() => context.push(AppRoutes.report);

  @override
  Widget build(BuildContext context) {
    // Includes the floating nav bar's height (the shell extends the body).
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: AmbientBackground(
        pine: null,
        clay: 0.06,
        clayTop: 500,
        child: SafeArea(
          bottom: false,
          child: ContentWidth(
            child: ScreenScroll(
              bottomInset: bottomInset,
              footer: const Padding(
                padding: EdgeInsets.only(
                  top: AppSpace.s24,
                  bottom: AppSpace.s26,
                ),
                child: NoteText(
                  'There is no right answer. We are looking at patterns '
                  'across all twelve, not at any single choice.',
                ),
              ),
              children: [
                ScreenTopBar(
                  title: 'Keep or let go',
                  onBack: () => context.go(AppRoutes.home),
                  trailing: TextButton(
                    onPressed: () {}, // Placeholder until the task engine.
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.ink3,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const TaskProgress(current: 4, total: 12, minutesLeft: 2),
                const SizedBox(height: AppSpace.s26),
                _ItemCard(onKeep: _choose, onLetGo: _choose),
                const SizedBox(height: AppSpace.s24),
                _DifficultyCard(
                  value: _difficulty,
                  onChanged: (v) => setState(() => _difficulty = v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The design's `.item` card: art, the question and the two choices.
class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.onKeep, required this.onLetGo});

  final VoidCallback onKeep;
  final VoidCallback onLetGo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s20,
        vertical: AppSpace.s22,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.item),
        border: Border.all(color: AppColors.line2, width: AppSizes.hairline),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Container(
            width: AppSizes.itemArt,
            height: AppSizes.itemArt,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.claySoft,
              shape: BoxShape.circle,
            ),
            child: const LineIcon(
              LineGlyphs.stack,
              size: AppSizes.itemArtIcon,
              color: AppColors.clay,
              strokeWidth: 1.8,
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          Text(
            "A stack of magazines you haven't opened since 2022",
            textAlign: TextAlign.center,
            style: AppTypography.heading,
          ),
          const SizedBox(height: AppSpace.s9),
          Text(
            'Imagine it is in front of you right now.',
            textAlign: TextAlign.center,
            style: AppTypography.small.copyWith(color: AppColors.ink3),
          ),
          const SizedBox(height: AppSpace.s16),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: 'Keep it',
                  style: PillStyle.ghost,
                  expand: true,
                  large: true,
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.s15),
                  onPressed: onKeep,
                ),
              ),
              const SizedBox(width: AppSpace.s11),
              Expanded(
                child: PillButton(
                  label: 'Let it go',
                  expand: true,
                  large: true,
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.s15),
                  onPressed: onLetGo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "How hard was that decision?" with a 0-4 scale.
class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s14,
        vertical: AppSpace.s15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('How hard was that decision?', style: AppTypography.smallSemi),
          // s11 in the design, less the 5px of hit padding around each cell.
          const SizedBox(height: AppSpace.s6),
          Row(
            children: [
              for (var i = 0; i <= 4; i++) ...[
                if (i > 0) const SizedBox(width: AppSpace.s7),
                Expanded(
                  child: _ScaleCell(
                    value: i,
                    selected: i == value,
                    onTap: () => onChanged(i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpace.s6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Not at all', style: AppTypography.captionSemi),
              Text('Extremely', style: AppTypography.captionSemi),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScaleCell extends StatelessWidget {
  const _ScaleCell({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meaning = switch (value) {
      0 => ', not at all hard',
      4 => ', extremely hard',
      _ => '',
    };
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: '$value of 4$meaning',
      excludeSemantics: true,
      child: PressScale(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          // The visible cell is 38px; the padding makes the hit area 48px.
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: (AppSizes.minTap - AppSizes.scaleCell) / 2,
            ),
            child: AnimatedContainer(
              duration: AppMotion.duration,
              curve: AppMotion.curve,
              height: AppSizes.scaleCell,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.pine : AppColors.screen,
                borderRadius: BorderRadius.circular(AppRadius.scaleCell),
                border: Border.all(
                  color: selected ? AppColors.pine : AppColors.line,
                  width: AppSizes.hairline,
                ),
              ),
              child: Text(
                '$value',
                style: AppTypography.smallSemi.copyWith(
                  color: selected ? AppColors.onPine : AppColors.ink3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
