import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/arc_motifs.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

/// The closing note on the sign-in screens.
const String kNoDiagnosisNote =
    'MindPath gives preliminary screening and self-support. It does not '
    'diagnose, and it is not a substitute for a clinician.';

/// Centres a screen body in a phone-width column (max 440).
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: child,
      ),
    );
  }
}

/// A scrollable screen body with 20px side padding. When the content is
/// shorter than the screen, [footer] is pushed to the bottom, like the
/// design's `flex:1` spacer before the closing note.
class ScreenScroll extends StatelessWidget {
  const ScreenScroll({
    super.key,
    required this.children,
    this.footer,
    this.bottomInset = 0,
  });

  final List<Widget> children;
  final Widget? footer;

  /// Extra space below everything, e.g. for a floating nav bar.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpace.s20,
          0,
          AppSpace.s20,
          bottomInset,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - bottomInset).clamp(
              0,
              double.infinity,
            ),
          ),
          // spaceBetween hands the spare height to the gap above the footer
          // without measuring intrinsics, which text fields under-report.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo mark, the name in Fraunces 38 and a short caption, as on the
/// sign-in screen.
class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.title = 'MindPath',
    required this.caption,
    this.centered = false,
  });

  final String title;
  final String caption;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        const LogoMark(),
        const SizedBox(height: AppSpace.s20),
        Semantics(
          header: true,
          child: Text(title, style: AppTypography.brand, textAlign: align),
        ),
        const SizedBox(height: AppSpace.s9),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _captionWidth),
          child: Text(
            caption,
            textAlign: align,
            style: AppTypography.lead.copyWith(color: AppColors.ink2),
          ),
        ),
      ],
    );
  }

  static const double _captionWidth = 250;
}

/// The design's `.note`: small ink-3 text with a 2px line rule on its left.
class NoteText extends StatelessWidget {
  const NoteText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: AppSpace.s10),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.line, width: AppSizes.noteRule),
        ),
      ),
      child: Text(text, style: AppTypography.caption.copyWith(height: 1.5)),
    );
  }
}

/// Back chevron, centred title and an optional trailing action, as on the
/// sorting and result screens.
class ScreenTopBar extends StatelessWidget {
  const ScreenTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.minTap,
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.minTap,
            child: Align(
              alignment: Alignment.centerLeft,
              child: onBack == null
                  ? null
                  : IconButton(
                      tooltip: 'Back',
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      onPressed: onBack,
                      icon: const LineIcon(
                        LineGlyphs.back,
                        color: AppColors.ink2,
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.smallBold,
              ),
            ),
          ),
          SizedBox(
            width: AppSizes.minTap,
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
        ],
      ),
    );
  }
}
