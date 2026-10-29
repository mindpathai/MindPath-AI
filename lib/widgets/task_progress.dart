import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';

/// The design's `.prog` bar with "Item X of Y" and the time remaining
/// underneath. Progress is always visible.
class TaskProgress extends StatelessWidget {
  const TaskProgress({
    super.key,
    required this.current,
    required this.total,
    required this.minutesLeft,
  });

  final int current;
  final int total;
  final int minutesLeft;

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : current.clamp(0, total) / total;
    final time = minutesLeft <= 1
        ? 'About a minute left'
        : 'About $minutesLeft min left';

    return Semantics(
      label: 'Item $current of $total, ${time.toLowerCase()}',
      excludeSemantics: true,
      child: Column(
        children: [
          Container(
            height: AppSizes.progressHeight,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.line2,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: value),
              duration: AppMotion.duration,
              curve: AppMotion.curve,
              builder: (context, v, _) => FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.pine,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Item $current of $total', style: AppTypography.captionSemi),
              Text(time, style: AppTypography.captionSemi),
            ],
          ),
        ],
      ),
    );
  }
}
