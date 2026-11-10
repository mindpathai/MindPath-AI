import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

/// Error line: a small clay info icon plus the message. The text stays in
/// ink-2 because clay is too light to read at caption size.
class ErrorLine extends StatelessWidget {
  const ErrorLine(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _StatusLine(
      glyph: LineGlyphs.info,
      color: AppColors.clay,
      message: message,
    );
  }
}

/// Success line: [ErrorLine]'s layout with a pine tick.
class SuccessLine extends StatelessWidget {
  const SuccessLine(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _StatusLine(
      glyph: LineGlyphs.ruleMet,
      color: AppColors.pine,
      message: message,
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.glyph,
    required this.color,
    required this.message,
  });

  final LineGlyph glyph;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LineIcon(glyph, size: AppSizes.iconSmall, color: color),
        const SizedBox(width: AppSpace.s6),
        Expanded(
          child: Text(
            message,
            style: AppTypography.caption.copyWith(color: AppColors.ink2),
          ),
        ),
      ],
    );
  }
}

/// Gently reveals a form-level message, an error unless [success] is set.
/// Shows nothing when null.
class FormMessage extends StatelessWidget {
  const FormMessage(this.message, {super.key, this.success = false});

  final String? message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final text = message;
    return AnimatedSize(
      duration: AppMotion.duration,
      curve: AppMotion.curve,
      child: text == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: AppSpace.s14),
              child: Semantics(
                liveRegion: true,
                child: success ? SuccessLine(text) : ErrorLine(text),
              ),
            ),
    );
  }
}
