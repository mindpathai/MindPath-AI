import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import 'package:mindpath_ai/theme/app_colors.dart';

/// Every gap and padding used in docs/mindpath-screens.html, named by its
/// pixel value. Use only these.
abstract final class AppSpace {
  static const double s2 = 2;
  static const double s3 = 3;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s7 = 7;
  static const double s8 = 8;
  static const double s9 = 9;
  static const double s10 = 10;
  static const double s11 = 11;
  static const double s12 = 12;
  static const double s13 = 13;
  static const double s14 = 14;
  static const double s15 = 15;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s22 = 22;
  static const double s24 = 24;
  static const double s26 = 26;
  static const double s30 = 30;
  static const double s38 = 38;
}

abstract final class AppRadius {
  /// Hero card, logo mark and the floating nav.
  static const double hero = 26;
  static const double card = 22;
  static const double badge = 14;
  static const double pill = 999;

  /// Sorting-task item card.
  static const double item = 24;
  static const double field = 15;
  static const double scaleCell = 12;
  static const double swatch = 3;
}

/// One soft shadow, tinted with ink, never grey.
abstract final class AppShadows {
  // CSS: 0 18px 40px -22px rgba(28,43,39,.45), 0 2px 6px -2px rgba(28,43,39,.10).
  // Flutter's blurRadius is converted to sigma as 0.57735r + 0.5, CSS blur
  // is 2 sigma, so 40px -> 33.8 and 6px -> 4.3.
  static final List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.45),
      offset: const Offset(0, 18),
      blurRadius: 33.8,
      spreadRadius: -22,
    ),
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.10),
      offset: const Offset(0, 2),
      blurRadius: 4.3,
      spreadRadius: -2,
    ),
  ];
}

/// One duration and curve for every animation. No bounce or spring.
abstract final class AppMotion {
  static const Duration duration = Duration(milliseconds: 240);
  static const Curve curve = Curves.easeOutCubic;

  /// Press-down feedback on tappable cards and buttons.
  static const Duration press = Duration(milliseconds: 120);
  static const double pressScale = 0.97;

  /// The selected mood face.
  static const double selectedScale = 1.08;
}

/// Fixed component dimensions from the design.
abstract final class AppSizes {
  static const double maxContentWidth = 440;
  static const double minTap = 48;

  static const double icon = 20;
  static const double iconSmall = 17;
  static const double iconStroke = 1.6;

  static const double logoMark = 84;
  static const double logoMarkOffset = 13;
  static const double logoArcs = 46;

  static const double avatar = 40;
  static const double badge = 44;
  static const double moodFace = 50;
  static const double moodIcon = 24;
  static const double ripple = 190;
  static const double ring = 54;

  static const double navHeight = 66;
  static const double navInsetH = 14;
  static const double navItemWidth = 42;
  static const double navItemHeight = 28;

  static const double progressHeight = 5;
  static const double itemArt = 110;
  static const double itemArtIcon = 56;
  static const double scaleCell = 38;
  static const double chartWidth = 192;
  static const double chartHeight = 118;
  static const double swatch = 9;
  static const double spinner = 20;

  static const double hairline = 1;
  static const double outline = 1.5;
  static const double noteRule = 2;
}
