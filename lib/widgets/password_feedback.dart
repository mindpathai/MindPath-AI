import 'package:flutter/material.dart';

import 'package:mindpath_ai/services/validators.dart';
import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

/// Three-segment strength meter plus the password rule checklist.
class PasswordFeedback extends StatelessWidget {
  const PasswordFeedback({super.key, required this.password});

  final String password;

  /// Label, filled segments and their colour per level. No red segment.
  static const Map<PasswordStrength, (String, int, Color)> _levels = {
    PasswordStrength.none: ('', 0, AppColors.line2),
    PasswordStrength.weak: ('Weak', 1, AppColors.clay),
    PasswordStrength.fair: ('Fair', 2, AppColors.peri),
    PasswordStrength.strong: ('Strong', 3, AppColors.sage),
  };

  @override
  Widget build(BuildContext context) {
    final (label, filled, color) = _levels[passwordStrength(password)]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: label.isEmpty ? null : 'Password strength: $label',
          excludeSemantics: true,
          child: Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: AppSpace.s4),
                Expanded(
                  child: AnimatedContainer(
                    duration: AppMotion.duration,
                    curve: AppMotion.curve,
                    height: AppSizes.progressHeight,
                    decoration: BoxDecoration(
                      color: i < filled ? color : AppColors.line2,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: AppSpace.s12),
              SizedBox(
                width: AppSizes.minTap,
                child: Text(label, style: AppTypography.caption),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.s12),
        for (final rule in kPasswordRules)
          _RuleRow(label: rule.label, met: rule.test(password)),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, ${met ? 'met' : 'not met'}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: AppMotion.duration,
              switchInCurve: AppMotion.curve,
              switchOutCurve: AppMotion.curve,
              child: LineIcon(
                met ? LineGlyphs.ruleMet : LineGlyphs.ruleOpen,
                key: ValueKey(met),
                color: met ? AppColors.sage : AppColors.ink3,
                size: AppSizes.iconSmall,
              ),
            ),
            const SizedBox(width: AppSpace.s8),
            Flexible(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: met ? AppColors.ink : AppColors.ink2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
