import 'package:flutter/painting.dart';

/// The only colours used in the app: a muted teal and a muted sage on warm
/// off-whites, with one earth tone and one alert tone. Do not add colours
/// elsewhere.
///
/// Why these (see DESIGN.md, "Why this palette"):
/// - De-saturated teal and sage lower arousal; saturated colour raises it,
///   and many users arrive anxious.
/// - No red or bright orange: both read as threat or warning. Even a high
///   screening result is information, not an alarm, so results use the calm
///   tones. The one muted terracotta ([clay]) is kept for real alerts only.
/// - Warm off-white behind dark grey-green ink: soft contrast without the
///   glare of pure black on pure white, still WCAG AA.
///
/// All readable text meets WCAG AA (4.5:1) on the screen, the cards and the
/// ambient tints; test/contrast_test.dart holds these pairs to it.
abstract final class AppColors {
  // Backdrops
  static const Color paper = Color(0xFFEDE8DD);
  static const Color paper2 = Color(0xFFE4DED1);
  static const Color screen = Color(0xFFF6F2EA);
  static const Color surface = Color(0xFFFCFAF5);

  // Ink
  static const Color ink = Color(0xFF25302C);
  static const Color ink2 = Color(0xFF46524C);
  static const Color ink3 = Color(0xFF5E6862);

  // Pine (primary)
  static const Color pine = Color(0xFF3C6467);
  static const Color pineSoft = Color(0xFFDDE7E5);

  // Clay: a muted terracotta, the only alert colour (SOS, field errors).
  // Never a primary, background or result colour, and no red anywhere.
  static const Color clay = Color(0xFFA5665A);
  static const Color claySoft = Color(0xFFF3E4DE);

  // Sage
  static const Color sage = Color(0xFF6E7F5C);
  static const Color sageSoft = Color(0xFFE4E8D9);

  // Sand: a quiet earth tone for low levels and in-between states.
  static const Color sand = Color(0xFF8A7A60);
  static const Color sandSoft = Color(0xFFECE5D8);

  // Lines
  static const Color line = Color(0xFFDEDBD0);
  static const Color line2 = Color(0xFFECE8DE);

  /// Outline of a control whose edge is its only cue (text fields, unchecked
  /// checkboxes): 3:1 on the screen and on cards. Decorative lines use [line].
  static const Color edge = Color(0xFF878B83);

  /// Text and strokes on pine fills (#fff in the design).
  static const Color onPine = Color(0xFFFFFFFF);

  /// Base of the shadow tint: ink, never grey.
  static const Color shadow = ink;

  /// Fully transparent, for scaffolds over the ambient background.
  static const Color transparent = Color(0x00F6F2EA);
}
