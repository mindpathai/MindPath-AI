import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

typedef NavItem = ({LineGlyph glyph, String label});

/// The design's `.nav`: a white bar inset 14px from the sides and 16px
/// from the bottom, radius 26. The active tab's icon sits on a pine-soft
/// pill. No badges or counters.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.navInsetH,
              0,
              AppSizes.navInsetH,
              AppSpace.s16,
            ),
            child: Container(
              height: AppSizes.navHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.hero),
                border: Border.all(
                  color: AppColors.line2,
                  width: AppSizes.hairline,
                ),
                boxShadow: AppShadows.soft,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavTab(
                        item: items[i],
                        selected: i == selectedIndex,
                        onTap: () => onSelected(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.pine : AppColors.ink3;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AppMotion.duration,
              curve: AppMotion.curve,
              width: AppSizes.navItemWidth,
              height: AppSizes.navItemHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.pineSoft : AppColors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: LineIcon(item.glyph, color: color),
            ),
            const SizedBox(height: AppSpace.s3),
            AnimatedDefaultTextStyle(
              duration: AppMotion.duration,
              curve: AppMotion.curve,
              style: AppTypography.captionSemi.copyWith(color: color),
              child: Text(item.label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}
