import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/utils/date_text.dart';
import 'package:mindpath_ai/widgets/app_buttons.dart';
import 'package:mindpath_ai/widgets/app_card.dart';
import 'package:mindpath_ai/widgets/arc_motifs.dart';
import 'package:mindpath_ai/widgets/icon_badge.dart';
import 'package:mindpath_ai/widgets/layout.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

/// Home header: date eyebrow and two-line greeting on the left; avatar
/// with the SOS chip under it on the right.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.firstName,
    required this.now,
    required this.onSos,
  });

  final String firstName;
  final DateTime now;
  final VoidCallback onSos;

  @override
  Widget build(BuildContext context) {
    final initial = firstName.isEmpty ? '?' : firstName[0].toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.s6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(longDate(now).toUpperCase(), style: AppTypography.eyebrow),
                const SizedBox(height: AppSpace.s7),
                Semantics(
                  header: true,
                  // Shrinks to fit at very large text, rather than cutting
                  // the greeting off.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${greetingFor(now)},\n$firstName',
                      style: AppTypography.display,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: AppSizes.avatar,
                  height: AppSizes.avatar,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.pineSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: AppTypography.strong.copyWith(color: AppColors.pine),
                  ),
                ),
              ),
              // The chip's 48px tap area supplies the gap under the avatar.
              SosChip(onTap: onSos),
            ],
          ),
        ],
      ),
    );
  }
}

/// "How do you feel?" card around the mood strip.
class MoodCard extends StatelessWidget {
  const MoodCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s14,
        vertical: AppSpace.s15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconBadge(LineGlyphs.mood, tone: Tone.sage),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: Text('How do you feel?', style: AppTypography.bodySemi),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s12),
          child,
        ],
      ),
    );
  }
}

/// Numbers a Dashboard section, so its place in the order reads without any
/// text. The [active] step is the one to do next.
class StepLabel extends StatelessWidget {
  const StepLabel({
    super.key,
    required this.number,
    required this.label,
    required this.active,
  });

  final int number;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.textScalerOf(context).scale(AppSizes.stepBadge);
    final duration = AppMotion.of(context);
    return Semantics(
      header: true,
      label: 'Step $number, $label',
      excludeSemantics: true,
      child: Row(
        children: [
          AnimatedContainer(
            duration: duration,
            curve: AppMotion.curve,
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.pine : AppColors.pineSoft,
              shape: BoxShape.circle,
            ),
            child: AnimatedDefaultTextStyle(
              duration: duration,
              curve: AppMotion.curve,
              style: AppTypography.tag.copyWith(
                color: active ? AppColors.onPine : AppColors.pine,
                letterSpacing: 0,
              ),
              child: Text('$number'),
            ),
          ),
          const SizedBox(width: AppSpace.s8),
          Expanded(
            child: Text(label.toUpperCase(), style: AppTypography.eyebrow),
          ),
        ],
      ),
    );
  }
}

/// The questions card with the ripple motif and the "Start" pill. Once
/// [active] it is the screen's dominant action; before that it stays quiet
/// so the first step leads. Start works in both states.
class CheckInHero extends StatelessWidget {
  const CheckInHero({super.key, required this.active, required this.onStart});

  final bool active;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context);
    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.curve,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        color: active ? AppColors.pine : AppColors.surface,
        border: Border.all(
          color: active ? AppColors.pine : AppColors.line2,
          width: AppSizes.hairline,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -56,
            top: -46,
            child: AnimatedOpacity(
              duration: duration,
              curve: AppMotion.curve,
              opacity: active ? 1 : 0,
              child: const RippleMotif(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconBadge(LineGlyphs.questions),
                const SizedBox(height: AppSpace.s12),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  curve: AppMotion.curve,
                  style: AppTypography.heading.copyWith(
                    color: active ? AppColors.onPine : AppColors.ink,
                  ),
                  child: const Text('Answer a few questions'),
                ),
                const SizedBox(height: AppSpace.s6),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  curve: AppMotion.curve,
                  style: AppTypography.small.copyWith(
                    color: active
                        ? AppColors.onPine.withValues(alpha: 0.78)
                        : AppColors.ink2,
                    height: 1.5,
                  ),
                  child: const Text(
                    'Five short tasks, about 8 minutes.\n'
                    'Pause any time — nothing is lost.',
                  ),
                ),
                const SizedBox(height: AppSpace.s16),
                PillButton(
                  label: 'Start',
                  style: active ? PillStyle.light : PillStyle.ghost,
                  icon: LineGlyphs.arrow,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.s20,
                    vertical: AppSpace.s12,
                  ),
                  onPressed: onStart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small card for a quick self-help action (the design's `.duo .card`).
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.glyph,
    required this.tone,
    required this.title,
    required this.caption,
    required this.onTap,
  });

  final LineGlyph glyph;
  final Tone tone;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.s14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(glyph, tone: tone),
          const SizedBox(height: AppSpace.s9),
          Text(title, style: AppTypography.strong),
          Text(caption, style: AppTypography.caption),
        ],
      ),
    );
  }
}

/// The two self-support exercises, side by side. The exercises arrive with
/// Therapy (Module 10); until then a tap says so rather than doing nothing.
class SupportOptions extends StatefulWidget {
  const SupportOptions({super.key});

  static const String soonMessage = 'This exercise is coming soon.';

  @override
  State<SupportOptions> createState() => _SupportOptionsState();
}

class _SupportOptionsState extends State<SupportOptions> {
  bool _showSoon = false;

  void _onTap() => setState(() => _showSoon = true);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: QuickActionCard(
                  glyph: LineGlyphs.breathe,
                  tone: Tone.pine,
                  title: 'Slow breathing',
                  caption: 'Two minutes',
                  onTap: _onTap,
                ),
              ),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: QuickActionCard(
                  glyph: LineGlyphs.senses,
                  tone: Tone.sage,
                  title: 'Calm your senses',
                  caption: 'Look, touch, listen',
                  onTap: _onTap,
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: AppMotion.of(context),
          curve: AppMotion.curve,
          child: _showSoon
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpace.s12),
                  child: Semantics(
                    liveRegion: true,
                    child: const NoteText(SupportOptions.soonMessage),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// The Wellness Fingerprint row. Its pattern needs three check-ins.
class WellnessFingerprintCard extends StatelessWidget {
  const WellnessFingerprintCard({super.key, this.checkIns = 0});

  final int checkIns;

  static const int needed = 3;

  String get _caption => switch (checkIns) {
    0 => 'Three check-ins and your pattern appears.',
    1 => 'One check-in done. Two more and your pattern appears.',
    2 => 'Two check-ins done. One more and your pattern appears.',
    _ => 'Your pattern is ready.',
  };

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              FingerprintRing(value: checkIns / needed),
              const LineIcon(LineGlyphs.progress, color: AppColors.pine),
            ],
          ),
          const SizedBox(width: AppSpace.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your progress', style: AppTypography.strong),
                const SizedBox(height: AppSpace.s3),
                Text(_caption, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable row card: badge, title and caption, chevron
/// (the design's `.card.area`).
class RowCard extends StatelessWidget {
  const RowCard({
    super.key,
    required this.glyph,
    required this.tone,
    required this.title,
    required this.caption,
    required this.onTap,
  });

  final LineGlyph glyph;
  final Tone tone;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s14,
        vertical: AppSpace.s13,
      ),
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(glyph, tone: tone),
          const SizedBox(width: AppSpace.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.strong),
                const SizedBox(height: AppSpace.s2),
                Text(caption, style: AppTypography.caption),
              ],
            ),
          ),
          const LineIcon(
            LineGlyphs.chevron,
            size: AppSizes.iconSmall,
            color: AppColors.ink3,
          ),
        ],
      ),
    );
  }
}
