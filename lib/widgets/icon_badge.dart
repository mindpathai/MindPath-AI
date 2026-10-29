import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

/// Colour pairs for badges and level tags.
enum Tone {
  pine(AppColors.pineSoft, AppColors.pine),
  clay(AppColors.claySoft, AppColors.clay),
  sage(AppColors.sageSoft, AppColors.sage);

  const Tone(this.soft, this.strong);

  final Color soft;
  final Color strong;
}

/// The design's `.badge`: a 44px rounded square (radius 14) with a line
/// icon in the tone's strong colour.
class IconBadge extends StatelessWidget {
  const IconBadge(this.glyph, {super.key, this.tone = Tone.pine});

  final LineGlyph glyph;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.badge,
      height: AppSizes.badge,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: LineIcon(glyph, color: tone.strong),
    );
  }
}
