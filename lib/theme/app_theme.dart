import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';

/// Wires the design tokens into Material so stock widgets match.
abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.pine).copyWith(
      primary: AppColors.pine,
      onPrimary: AppColors.onPine,
      primaryContainer: AppColors.pineSoft,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.clay,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.ink2,
      outline: AppColors.edge,
      outlineVariant: AppColors.line,
      error: AppColors.clay,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.screen,
      textTheme: AppTypography.textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.ink2,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.smallBold,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pine,
          textStyle: AppTypography.smallSemi,
          shape: const StadiumBorder(),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.ink2),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: AppColors.edge, width: AppSizes.outline),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.pine : null,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.onPine),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.pine,
        titleTextStyle: AppTypography.small,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.pine,
        linearTrackColor: AppColors.line2,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
