import 'package:flutter/painting.dart';

/// The only colours used in the app, ported from the :root block of
/// docs/mindpath-screens.html (light values). Do not add colours elsewhere.
///
/// [ink2] and [ink3] are darker than the mockup so all readable text meets
/// WCAG AA (4.5:1) on the screen, white cards and the ambient tints.
abstract final class AppColors {
  // Backdrops
  static const Color paper = Color(0xFFE9ECE7);
  static const Color paper2 = Color(0xFFDFE4DE);
  static const Color screen = Color(0xFFF7F8F5);
  static const Color surface = Color(0xFFFFFFFF);

  // Ink
  static const Color ink = Color(0xFF1C2B27);
  static const Color ink2 = Color(0xFF42514C);
  static const Color ink3 = Color(0xFF5F6C67);

  // Pine (primary)
  static const Color pine = Color(0xFF2F5D56);
  static const Color pineDeep = Color(0xFF1E423D);
  static const Color pineSoft = Color(0xFFDEEAE6);

  // Clay (SOS, high levels, errors; no red anywhere)
  static const Color clay = Color(0xFFCE8463);
  static const Color claySoft = Color(0xFFF6E5DA);

  // Sage
  static const Color sage = Color(0xFF6F8E76);
  static const Color sageSoft = Color(0xFFE2EBE1);

  static const Color peri = Color(0xFF7E90BB);

  // Lines
  static const Color line = Color(0xFFD9E0DA);
  static const Color line2 = Color(0xFFE8EDE8);

  /// Outline of a control whose edge is its only cue (text fields, unchecked
  /// checkboxes): 3:1 on the screen and on white. Decorative lines use [line].
  static const Color edge = Color(0xFF87918C);

  /// Text and strokes on pine fills (#fff in the design).
  static const Color onPine = Color(0xFFFFFFFF);

  /// Base of the shadow tint: ink, never grey.
  static const Color shadow = ink;

  /// Fully transparent, for scaffolds over the ambient background.
  static const Color transparent = Color(0x00F7F8F5);
}
