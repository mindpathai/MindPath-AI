import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:mindpath_ai/theme/app_colors.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// [color] at [alpha] over the opaque [base].
Color _over(Color color, double alpha, Color base) =>
    Color.alphaBlend(color.withValues(alpha: alpha), base);

void main() {
  final tints = {
    'screen': AppColors.screen,
    'surface': AppColors.surface,
    'pine tint': _over(AppColors.pine, 0.07, AppColors.screen),
    'sage tint': _over(AppColors.sage, 0.07, AppColors.screen),
  };

  final text = <String, (Color, Color)>{
    for (final MapEntry(key: name, value: bg) in tints.entries) ...{
      'ink on $name': (AppColors.ink, bg),
      'ink2 on $name': (AppColors.ink2, bg),
      'ink3 on $name': (AppColors.ink3, bg),
      'pine on $name': (AppColors.pine, bg),
    },
    'ink3 on pineSoft': (AppColors.ink3, AppColors.pineSoft),
    'pine on pineSoft': (AppColors.pine, AppColors.pineSoft),
    'ink on claySoft': (AppColors.ink, AppColors.claySoft),
    'ink on sageSoft': (AppColors.ink, AppColors.sageSoft),
    'ink on sandSoft': (AppColors.ink, AppColors.sandSoft),
    'ink2 on surface (helpline notes)': (AppColors.ink2, AppColors.surface),
    'onPine on pine': (AppColors.onPine, AppColors.pine),
    'hero subtext on pine': (
      _over(AppColors.onPine, 0.78, AppColors.pine),
      AppColors.pine,
    ),
    'ink3 on line2 (disabled pill)': (AppColors.ink3, AppColors.line2),
  };

  final graphics = <String, (Color, Color)>{
    'edge on screen': (AppColors.edge, AppColors.screen),
    'edge on surface': (AppColors.edge, AppColors.surface),
    'sage on surface': (AppColors.sage, AppColors.surface),
    'sage on sageSoft': (AppColors.sage, AppColors.sageSoft),
    'pine on surface': (AppColors.pine, AppColors.surface),
    'clay on surface': (AppColors.clay, AppColors.surface),
    'clay on claySoft': (AppColors.clay, AppColors.claySoft),
    'sand on surface': (AppColors.sand, AppColors.surface),
    'sand on sandSoft': (AppColors.sand, AppColors.sandSoft),
    'sand on line2 (weak password bar)': (AppColors.sand, AppColors.line2),
  };

  group('Text meets 4.5:1', () {
    text.forEach((name, pair) {
      test(name, () {
        expect(_contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
      });
    });
  });

  group('Icons and outlines meet 3:1', () {
    graphics.forEach((name, pair) {
      test(name, () {
        expect(_contrast(pair.$1, pair.$2), greaterThanOrEqualTo(3));
      });
    });
  });
}
