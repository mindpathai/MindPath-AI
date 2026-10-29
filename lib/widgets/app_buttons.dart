import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';
import 'package:mindpath_ai/widgets/press_scale.dart';

/// The design's `.pill` variants.
enum PillStyle {
  /// Pine fill, white text: the screen's one main action.
  solid,

  /// White fill, pine text: for use on the pine hero card.
  light,

  /// Transparent with a 1.5px line border.
  ghost,
}

/// Pill-shaped button. A null [onPressed] disables it; [loading] shows a
/// spinner in place of the label. [expand] makes it full width.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = PillStyle.solid,
    this.icon,
    this.expand = false,
    this.large = false,
    this.loading = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpace.s18,
      vertical: AppSpace.s12,
    ),
  });

  /// Full-width solid pill used for form submits (padding 16px 0).
  const PillButton.submit({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  }) : style = PillStyle.solid,
       icon = null,
       expand = true,
       large = true,
       padding = const EdgeInsets.symmetric(vertical: AppSpace.s16);

  final String label;
  final VoidCallback? onPressed;
  final PillStyle style;
  final LineGlyph? icon;
  final bool expand;

  /// 15px label instead of 14px.
  final bool large;
  final bool loading;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final (fill, ink) = switch (style) {
      PillStyle.solid => (AppColors.pine, AppColors.onPine),
      PillStyle.light => (AppColors.surface, AppColors.pine),
      PillStyle.ghost => (AppColors.transparent, AppColors.ink),
    };
    final enabled = onPressed != null && !loading;

    final content = loading
        ? SizedBox.square(
            key: const ValueKey('spinner'),
            dimension: AppSizes.iconSmall,
            child: CircularProgressIndicator(strokeWidth: 2, color: ink),
          )
        : Row(
            key: ValueKey(label),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              if (icon != null) ...[
                const SizedBox(width: AppSpace.s7),
                LineIcon(icon!, size: AppSizes.iconSmall),
              ],
            ],
          );

    final button = FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: fill,
        foregroundColor: ink,
        // Keep the normal fill while loading so the spinner stays visible.
        disabledBackgroundColor: loading ? fill : AppColors.line2,
        disabledForegroundColor: loading ? ink : AppColors.ink3,
        textStyle: large ? AppTypography.buttonLarge : AppTypography.button,
        padding: padding,
        minimumSize: Size.zero,
        // Pads the hit area (not the pill) out to 48x48.
        tapTargetSize: MaterialTapTargetSize.padded,
        elevation: 0,
        shape: const StadiumBorder(),
        side: style == PillStyle.ghost
            ? const BorderSide(color: AppColors.line, width: AppSizes.outline)
            : null,
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.duration,
        switchInCurve: AppMotion.curve,
        switchOutCurve: AppMotion.curve,
        child: content,
      ),
    );

    return PressScale(
      enabled: enabled,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

/// The design's `.sos` chip: ink text on a clay-soft pill. The visible pill
/// sits inside a 48px-tall tap area so it stays easy to hit.
class SosChip extends StatelessWidget {
  const SosChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'SOS, get help now',
      excludeSemantics: true,
      child: PressScale(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: AppSizes.minTap,
            child: Center(
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.claySoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.s12,
                    vertical: AppSpace.s6,
                  ),
                  // Ink, not clay: clay text on clay-soft is about 2.3:1.
                  child: Text(
                    'SOS',
                    style: AppTypography.tag.copyWith(color: AppColors.ink),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pine text link with press feedback and a 48px tap area.
class LinkButton extends StatelessWidget {
  const LinkButton({super.key, required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      enabled: onPressed != null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSizes.minTap, AppSizes.minTap),
          padding: EdgeInsets.zero,
        ),
        child: child,
      ),
    );
  }
}
