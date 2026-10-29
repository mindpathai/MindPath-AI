import 'package:flutter/widgets.dart';

import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';

/// A stroke icon defined by SVG path data, as drawn in the design.
class LineGlyph {
  const LineGlyph(this.paths, {this.viewBox = 24});

  final List<String> paths;
  final double viewBox;
}

/// The design's inline SVG icons, path data copied verbatim
/// (circles and rects rewritten as paths).
abstract final class LineGlyphs {
  static const eye = LineGlyph([
    'M2 12s3.6-6.5 10-6.5S22 12 22 12s-3.6 6.5-10 6.5S2 12 2 12Z',
    'M9.4 12a2.6 2.6 0 1 0 5.2 0a2.6 2.6 0 1 0 -5.2 0',
  ]);

  /// [eye] with a slash, for the "hide password" state.
  static const eyeOff = LineGlyph([
    'M2 12s3.6-6.5 10-6.5S22 12 22 12s-3.6 6.5-10 6.5S2 12 2 12Z',
    'M9.4 12a2.6 2.6 0 1 0 5.2 0a2.6 2.6 0 1 0 -5.2 0',
    'M4 4l16 16',
  ]);

  // Status: drawn on the same 24 grid as the rest, one circle shared.
  static const _ring = 'M3.5 12a8.5 8.5 0 1 0 17 0a8.5 8.5 0 1 0 -17 0';

  /// Form errors. The dot is a zero-length round-capped stroke, like the
  /// mood faces' eyes.
  static const info = LineGlyph([_ring, 'M12 11v5', 'M12 7.9h.01']);

  /// A password rule that is met.
  static const ruleMet = LineGlyph([_ring, 'M8.4 12.3l2.5 2.5 4.7-5']);

  /// A password rule not met yet.
  static const ruleOpen = LineGlyph([_ring]);

  static const back = LineGlyph(['M15 6l-6 6 6 6']);
  static const chevron = LineGlyph(['M9 6l6 6-6 6']);
  static const arrow = LineGlyph(['M5 12h13M13 6l6 6-6 6']);
  static const share = LineGlyph([
    'M12 15V4M8 8l4-4 4 4',
    'M5 15v3.5A1.5 1.5 0 0 0 6.5 20h11a1.5 1.5 0 0 0 1.5-1.5V15',
  ]);

  static const breathe = LineGlyph([
    'M12 20c3.9 0 7-2.4 7-5.5S15.9 9 12 9s-7 2.4-7 5.5S8.1 20 12 20Z',
    'M12 9V4M9 6l3-2 3 2',
  ]);
  static const ground = LineGlyph([
    'M12 21V9',
    'M12 9c0-3.3 2.7-6 6-6 0 3.3-2.7 6-6 6Z',
    'M12 14c0-2.8-2.2-5-5-5 0 2.8 2.2 5 5 5Z',
  ]);
  static const ladder = LineGlyph([
    'M12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1'
        'M18.4 5.6l-2.1 2.1M7.7 16.3l-2.1 2.1',
  ]);

  // Bottom navigation
  static const home = LineGlyph([
    'M4 10.5 12 4l8 6.5V19a1 1 0 0 1-1 1h-4v-5h-6v5H5a1 1 0 0 1-1-1Z',
  ]);
  static const checkIn = LineGlyph([
    'M7.5 4h9a2.5 2.5 0 0 1 2.5 2.5v12a2.5 2.5 0 0 1 -2.5 2.5h-9'
        'a2.5 2.5 0 0 1 -2.5 -2.5v-12a2.5 2.5 0 0 1 2.5 -2.5z',
    'M9 3.5h6v2.5H9zM9 11h6M9 15h4',
  ]);
  static const therapy = LineGlyph([
    'M12 21V10',
    'M12 10c0-3.3 2.7-6 6-6 0 3.3-2.7 6-6 6Z',
    'M12 15c0-2.8-2.2-5-5-5 0 2.8 2.2 5 5 5Z',
  ]);
  static const progress = LineGlyph(['M4 19h16M7 16V9M12 16V5M17 16v-4']);
  static const you = LineGlyph([
    'M8.4 8.5a3.6 3.6 0 1 0 7.2 0a3.6 3.6 0 1 0 -7.2 0',
    'M5 20c.8-3.5 3.6-5.3 7-5.3s6.2 1.8 7 5.3',
  ]);

  /// Sorting-task art: a stack of magazines (56 viewBox).
  static const stack = LineGlyph([
    'M13 33h30a2 2 0 0 1 2 2v4a2 2 0 0 1 -2 2h-30a2 2 0 0 1 -2 -2v-4'
        'a2 2 0 0 1 2 -2z',
    'M16 25h24a2 2 0 0 1 2 2v4a2 2 0 0 1 -2 2h-24a2 2 0 0 1 -2 -2v-4'
        'a2 2 0 0 1 2 -2z',
    'M19 17h18a2 2 0 0 1 2 2v4a2 2 0 0 1 -2 2h-18a2 2 0 0 1 -2 -2v-4'
        'a2 2 0 0 1 2 -2z',
  ], viewBox: 56);
}

/// Paints a [LineGlyph] with round caps and joins, like the design's `.ico`.
/// The colour defaults to the ambient [IconTheme] colour.
class LineIcon extends StatelessWidget {
  const LineIcon(
    this.glyph, {
    super.key,
    this.size = AppSizes.icon,
    this.color,
    this.strokeWidth = AppSizes.iconStroke,
  });

  final LineGlyph glyph;
  final double size;
  final Color? color;

  /// In viewBox units, as in the SVG.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LineIconPainter(
          glyph,
          color ?? IconTheme.of(context).color ?? AppColors.ink,
          strokeWidth,
        ),
      ),
    );
  }
}

class _LineIconPainter extends CustomPainter {
  _LineIconPainter(this.glyph, this.color, this.strokeWidth);

  final LineGlyph glyph;
  final Color color;
  final double strokeWidth;

  static final Expando<List<Path>> _cache = Expando();

  @override
  void paint(Canvas canvas, Size size) {
    final paths = _cache[glyph] ??= [
      for (final d in glyph.paths) parseSvgPath(d),
    ];
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..color = color;
    canvas.scale(size.width / glyph.viewBox);
    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LineIconPainter old) =>
      old.glyph != glyph ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

final RegExp _token = RegExp(
  r'[MmLlHhVvCcSsAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?',
);
final RegExp _command = RegExp('[A-Za-z]');

/// Parses the SVG path commands the design uses (M L H V C S A Z, absolute
/// and relative) into a [Path].
Path parseSvgPath(String data) {
  final tokens = [for (final m in _token.allMatches(data)) m[0]!];
  final path = Path();
  var i = 0;
  var cmd = '';
  var x = 0.0, y = 0.0, startX = 0.0, startY = 0.0;
  Offset? lastControl;

  double next() => double.parse(tokens[i++]);

  while (i < tokens.length) {
    if (_command.hasMatch(tokens[i])) {
      cmd = tokens[i++];
    } else if (cmd.isEmpty || cmd == 'Z' || cmd == 'z') {
      throw FormatException('Number without a command', data);
    } else if (cmd == 'M') {
      cmd = 'L'; // Extra pairs after a moveto are linetos.
    } else if (cmd == 'm') {
      cmd = 'l';
    }
    final relative = cmd == cmd.toLowerCase();
    final ox = relative ? x : 0.0;
    final oy = relative ? y : 0.0;
    Offset? control;

    switch (cmd.toUpperCase()) {
      case 'M':
        x = ox + next();
        y = oy + next();
        path.moveTo(x, y);
        startX = x;
        startY = y;
      case 'L':
        x = ox + next();
        y = oy + next();
        path.lineTo(x, y);
      case 'H':
        x = ox + next();
        path.lineTo(x, y);
      case 'V':
        y = oy + next();
        path.lineTo(x, y);
      case 'C':
        final c1 = Offset(ox + next(), oy + next());
        control = Offset(ox + next(), oy + next());
        x = ox + next();
        y = oy + next();
        path.cubicTo(c1.dx, c1.dy, control.dx, control.dy, x, y);
      case 'S':
        final c1 = lastControl == null
            ? Offset(x, y)
            : Offset(2 * x - lastControl.dx, 2 * y - lastControl.dy);
        control = Offset(ox + next(), oy + next());
        x = ox + next();
        y = oy + next();
        path.cubicTo(c1.dx, c1.dy, control.dx, control.dy, x, y);
      case 'A':
        final rx = next(), ry = next(), rotation = next();
        final largeArc = next() != 0, sweep = next() != 0;
        x = ox + next();
        y = oy + next();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: largeArc,
          clockwise: sweep,
        );
      case 'Z':
        path.close();
        x = startX;
        y = startY;
      default:
        throw FormatException('Unsupported path command "$cmd"', data);
    }
    lastControl = control;
  }
  return path;
}
