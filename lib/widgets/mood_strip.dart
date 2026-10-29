import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';
import 'package:mindpath_ai/widgets/press_scale.dart';

/// Five faces from "Very low" to "Great". Starts on the middle one;
/// selection is local state only for now.
class MoodStrip extends StatefulWidget {
  const MoodStrip({super.key});

  @override
  State<MoodStrip> createState() => _MoodStripState();
}

class _MoodStripState extends State<MoodStrip> {
  int _selected = 2;

  // Mouth paths from the design; the eyes are shared.
  static const _eyes = 'M8.5 9.5h.01M15.5 9.5h.01';
  static const _moods = [
    ('Very low', 'M8 16.5c1-1.8 2.3-2.7 4-2.7s3 .9 4 2.7'),
    ('Low', 'M8.5 15.6c1-.9 2.1-1.4 3.5-1.4s2.5.5 3.5 1.4'),
    ('Okay', 'M8.6 14.8h6.8'),
    ('Good', 'M8.5 14c1 .9 2.1 1.4 3.5 1.4s2.5-.5 3.5-1.4'),
    ('Great', 'M8 13.3c1 1.8 2.3 2.7 4 2.7s3-.9 4-2.7'),
  ];
  static final _glyphs = [
    for (final (_, mouth) in _moods) LineGlyph([mouth, _eyes]),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _moods.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpace.s6),
          Expanded(
            child: _MoodOption(
              label: _moods[i].$1,
              glyph: _glyphs[i],
              selected: i == _selected,
              onTap: () => setState(() => _selected = i),
            ),
          ),
        ],
      ],
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({
    required this.label,
    required this.glyph,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final LineGlyph glyph;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: label,
      excludeSemantics: true,
      child: PressScale(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              AnimatedScale(
                scale: selected ? AppMotion.selectedScale : 1,
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : AppMotion.duration,
                curve: AppMotion.curve,
                child: AnimatedContainer(
                  duration: AppMotion.duration,
                  curve: AppMotion.curve,
                  width: AppSizes.moodFace,
                  height: AppSizes.moodFace,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.sageSoft : AppColors.screen,
                    border: Border.all(
                      color: selected ? AppColors.sage : AppColors.line,
                      width: AppSizes.outline,
                    ),
                  ),
                  child: LineIcon(
                    glyph,
                    size: AppSizes.moodIcon,
                    color: selected ? AppColors.sage : AppColors.ink3,
                    strokeWidth: selected ? 1.9 : 1.7,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.s6),
              AnimatedDefaultTextStyle(
                duration: AppMotion.duration,
                curve: AppMotion.curve,
                // Ink, not sage: sage text is 3.6:1 at caption size. The
                // face's fill and border carry the tone.
                style: AppTypography.captionSemi.copyWith(
                  color: selected ? AppColors.ink : AppColors.ink3,
                ),
                child: Text(label, maxLines: 1, softWrap: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
