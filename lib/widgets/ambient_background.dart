import 'package:flutter/widgets.dart';

import 'package:mindpath_ai/theme/app_colors.dart';

/// The design's `.amb` shapes: the screen colour with a pine circle off
/// the top-right corner and a clay circle off the left edge, both faint.
/// Pass null for [pine] or [clay] to leave that circle out.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.pine = 0.07,
    this.clay = 0.07,
    this.clayTop = 280,
  });

  final Widget child;

  /// Opacity of the 300px pine circle (right -130, top -90).
  final double? pine;

  /// Opacity of the 230px clay circle (left -120, top [clayTop]).
  final double? clay;
  final double clayTop;

  @override
  Widget build(BuildContext context) {
    final pine = this.pine, clay = this.clay;
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
          if (clay != null)
            Positioned(
              left: -120,
              top: clayTop,
              child: _Circle(230, AppColors.clay.withValues(alpha: clay)),
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
