import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpath_ai/theme/app_colors.dart';

/// The type scale. Only these sizes exist: 38, 31, 25, 23, 15, 14, 13.5,
/// 11.5. Fraunces is for greetings, questions and result headlines;
/// Hanken Grotesk is for everything else.
abstract final class AppTypography {
  static TextStyle _fraunces(
    double size, {
    double? height,
    double em = -0.02,
  }) => GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: FontWeight.w500,
    height: height,
    letterSpacing: size * em,
    color: AppColors.ink,
  );

  static TextStyle _hanken(
    double size,
    FontWeight weight, {
    double? height,
    double em = 0,
    Color color = AppColors.ink,
  }) => GoogleFonts.hankenGrotesk(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: em == 0 ? null : size * em,
    color: color,
  );

  // Fraunces w500
  /// Brand name on the sign-in screen.
  static TextStyle get brand => _fraunces(38, height: 1.1);

  /// Greetings.
  static TextStyle get display => _fraunces(31, height: 1.1);

  /// Result headlines.
  static TextStyle get title => _fraunces(25, height: 1.1);

  /// Card headlines and task questions.
  static TextStyle get heading => _fraunces(23, height: 1.25, em: -0.015);

  // Hanken Grotesk
  static TextStyle get lead => _hanken(15, FontWeight.w400, height: 1.55);
  static TextStyle get strong => _hanken(15, FontWeight.w700);

  /// Text typed into a field.
  static TextStyle get field => _hanken(15, FontWeight.w500);
  static TextStyle get body => _hanken(14, FontWeight.w400);
  static TextStyle get bodySemi => _hanken(14, FontWeight.w600);
  static TextStyle get small => _hanken(13.5, FontWeight.w400);
  static TextStyle get smallSemi => _hanken(13.5, FontWeight.w600);
  static TextStyle get smallBold => _hanken(13.5, FontWeight.w700);
  static TextStyle get button => _hanken(14, FontWeight.w600);
  static TextStyle get buttonLarge => _hanken(15, FontWeight.w600);
  static TextStyle get caption =>
      _hanken(11.5, FontWeight.w400, height: 1.4, color: AppColors.ink3);
  static TextStyle get captionSemi =>
      _hanken(11.5, FontWeight.w600, color: AppColors.ink3);

  /// Uppercase date and section lines (pass upper-cased text).
  static TextStyle get eyebrow =>
      _hanken(11.5, FontWeight.w600, em: 0.09, color: AppColors.ink3);

  /// Uppercase field labels (pass upper-cased text).
  static TextStyle get fieldLabel =>
      _hanken(11.5, FontWeight.w600, em: 0.06, color: AppColors.ink3);

  /// SOS chip and level tags (pass upper-cased text).
  static TextStyle get tag => _hanken(11.5, FontWeight.w700, em: 0.08);

  /// High / Medium / Low tags on the result (pass upper-cased text).
  static TextStyle get levelTag => _hanken(11.5, FontWeight.w700, em: 0.05);

  /// Maps Material's slots onto the scale so stock widgets stay on it too.
  static TextTheme get textTheme => TextTheme(
    displayLarge: brand,
    displayMedium: display,
    displaySmall: display,
    headlineLarge: title,
    headlineMedium: title,
    headlineSmall: heading,
    titleLarge: heading,
    titleMedium: strong,
    titleSmall: smallBold,
    bodyLarge: lead,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: button,
    labelMedium: captionSemi,
    labelSmall: captionSemi,
  );
}
