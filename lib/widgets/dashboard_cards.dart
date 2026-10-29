import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/utils/date_text.dart';
import 'package:mindpath_ai/widgets/app_buttons.dart';
import 'package:mindpath_ai/widgets/app_card.dart';
import 'package:mindpath_ai/widgets/arc_motifs.dart';
import 'package:mindpath_ai/widgets/icon_badge.dart';
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
                  child: Text(
                    '${greetingFor(now)},\n$firstName',
                    style: AppTypography.display,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

/// "How are you right now?" card around the mood strip.
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
          Text('How are you right now?', style: AppTypography.bodySemi),
          const SizedBox(height: AppSpace.s12),
          child,
        ],
      ),
    );
  }
}

/// The pine hero card with the ripple motif and a light "Begin" pill.
class CheckInHero extends StatelessWidget {
  const CheckInHero({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        // CSS linear-gradient(145deg): left-to-right turned 55deg clockwise.
        gradient: const LinearGradient(
          colors: [AppColors.pine, AppColors.pineDeep],
          transform: GradientRotation(55 * math.pi / 180),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(right: -56, top: -46, child: RippleMotif()),
          Padding(
            padding: const EdgeInsets.all(AppSpace.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start your check-in',
                  style: AppTypography.heading.copyWith(
                    color: AppColors.onPine,
                  ),
                ),
                const SizedBox(height: AppSpace.s6),
                Text(
                  'Five short tasks, about 8 minutes.\n'
                  'Pause any time — nothing is lost.',
                  style: AppTypography.small.copyWith(
                    color: AppColors.onPine.withValues(alpha: 0.78),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpace.s16),
                PillButton(
                  label: 'Begin',
                  style: PillStyle.light,
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
          FingerprintRing(value: checkIns / needed),
          const SizedBox(width: AppSpace.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Wellness Fingerprint', style: AppTypography.strong),
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
