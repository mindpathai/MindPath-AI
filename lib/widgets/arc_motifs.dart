import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';

// Concentric arcs are the brand motif. They appear three times: the logo
// mark, the hero card's ripple and the result chart.

/// The app's logo: a pine rounded square with three rising arcs, and a
/// clay square offset behind it.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.hero);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: AppSizes.logoMark,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: AppSizes.logoMarkOffset,
              top: AppSizes.logoMarkOffset,
              width: AppSizes.logoMark,
              height: AppSizes.logoMark,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.clay.withValues(alpha: 0.28),
                  borderRadius: radius,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.pine,
                borderRadius: radius,
              ),
              child: const Center(
                child: SizedBox.square(
                  dimension: AppSizes.logoArcs,
                  child: CustomPaint(painter: _LogoArcsPainter()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoArcsPainter extends CustomPainter {
  const _LogoArcsPainter();

  // viewBox 48: semicircles centred on (24, 34), radius and opacity.
  static const _arcs = [(18.0, 0.45), (11.0, 0.75), (4.0, 1.0)];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48);
    for (final (radius, opacity) in _arcs) {
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(24, 34), radius: radius),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = AppColors.onPine.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_LogoArcsPainter old) => false;
}

/// Four settling rings, drawn in white at 26% on the hero card.
class RippleMotif extends StatelessWidget {
  const RippleMotif({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: SizedBox.square(
        dimension: AppSizes.ripple,
        child: CustomPaint(painter: _RipplePainter()),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  const _RipplePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / AppSizes.ripple);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = AppColors.onPine.withValues(alpha: 0.26);
    for (final r in const [30.0, 48.0, 66.0, 84.0]) {
      canvas.drawCircle(const Offset(95, 95), r, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => false;
}

/// One ring of the result chart: how far along its half-circle it fills
/// (0 to 1) and its colour.
typedef ArcBand = ({double value, Color color});

/// The result chart: up to six concentric half-rings, outermost first,
/// each filled from the left.
class ArcChart extends StatelessWidget {
  const ArcChart({super.key, required this.bands});

  final List<ArcBand> bands;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: AppSizes.chartWidth,
        height: AppSizes.chartHeight,
        child: CustomPaint(painter: _ArcChartPainter(bands)),
      ),
    );
  }
}

class _ArcChartPainter extends CustomPainter {
  _ArcChartPainter(this.bands);

  final List<ArcBand> bands;

  // viewBox 192 x 118: rings centred on (96, 110).
  static const _radii = [80.0, 66.0, 52.0, 38.0, 24.0, 10.0];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / AppSizes.chartWidth);
    Paint stroke(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = color;

    Rect ring(double r) =>
        Rect.fromCircle(center: const Offset(96, 110), radius: r);

    for (final r in _radii) {
      canvas.drawArc(ring(r), math.pi, math.pi, false, stroke(AppColors.line2));
    }
    for (var i = 0; i < bands.length && i < _radii.length; i++) {
      final band = bands[i];
      if (band.value <= 0) continue;
      canvas.drawArc(
        ring(_radii[i]),
        math.pi,
        math.pi * band.value.clamp(0.0, 1.0),
        false,
        stroke(band.color),
      );
    }
  }

  @override
  bool shouldRepaint(_ArcChartPainter old) => old.bands != bands;
}

/// The Wellness Fingerprint ring: a dashed track with a clay arc from
/// the top for [value] (0 to 1).
class FingerprintRing extends StatelessWidget {
  const FingerprintRing({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: AppSizes.ring,
        child: CustomPaint(painter: _FingerprintRingPainter(value)),
      ),
    );
  }
}

class _FingerprintRingPainter extends CustomPainter {
  _FingerprintRingPainter(this.value);

  final double value;

  // viewBox 54: r 23, stroke 5, dash 3 gap 5, round caps.
  static const _r = 23.0;
  static const _dash = 3.0;
  static const _gap = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / AppSizes.ring);
    const center = Offset(27, 27);
    final rect = Rect.fromCircle(center: center, radius: _r);
    Paint stroke(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color;

    // SVG dashes start at 3 o'clock and run clockwise.
    final track = stroke(AppColors.line);
    const step = (_dash + _gap) / _r;
    for (var a = 0.0; a < 2 * math.pi - 1e-6; a += step) {
      final sweep = math.min(_dash / _r, 2 * math.pi - a);
      canvas.drawArc(rect, a, sweep, false, track);
    }

    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * value.clamp(0.0, 1.0),
        false,
        stroke(AppColors.clay),
      );
    }
  }

  @override
  bool shouldRepaint(_FingerprintRingPainter old) => old.value != value;
}
