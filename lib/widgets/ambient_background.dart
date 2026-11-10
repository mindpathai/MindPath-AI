import 'package:flutter/widgets.dart';

import 'package:mindpath_ai/theme/app_colors.dart';

/// The design's `.amb` shapes: the screen colour with a pine circle off
/// the top-right corner and a sage circle off the left edge, both faint.
/// Pass null for [pine] or [sage] to leave that circle out.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.pine = 0.07,
    this.sage = 0.07,
    this.sageTop = 280,
  });

  final Widget child;

  /// Opacity of the 300px pine circle (right -130, top -90).
  final double? pine;

  /// Opacity of the 230px sage circle (left -120, top [sageTop]).
  final double? sage;
  final double sageTop;

  @override
  Widget build(BuildContext context) {
    final pine = this.pine, sage = this.sage;
    return ColoredBox(
      color: AppColors.screen,
      child: Stack(
        children: [
          if (pine != null)
            Positioned(
              right: -130,
              top: -90,
              child: _Circle(300, AppColors.pine.withValues(alpha: pine)),
            ),
          if (sage != null)
            Positioned(
              left: -120,
              top: sageTop,
              child: _Circle(230, AppColors.sage.withValues(alpha: sage)),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(this.size, this.color);

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
