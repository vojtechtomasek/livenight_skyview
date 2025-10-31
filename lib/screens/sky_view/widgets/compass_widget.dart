import 'package:flutter/material.dart';

class CompassWidget extends StatelessWidget {
  final double heading;        // azimut [0..360)
  final double fovDegrees;     // šířka škály
  final Color color;
  final Color markerColor;

  const CompassWidget({
    super.key,
    required this.heading,
    this.fovDegrees = 120,
    this.color = Colors.white,
    this.markerColor = const Color(0xFF8AB4F8),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CompassPainter(
        heading: heading,
        fov: fovDegrees.clamp(30, 180),
        color: color,
        markerColor: markerColor,
        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: .75),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
      ),
      size: const Size.fromHeight(64),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  final double fov;
  final Color color;
  final Color markerColor;
  final TextStyle? textStyle;

  _CompassPainter({
    required this.heading,
    required this.fov,
    required this.color,
    required this.markerColor,
    required this.textStyle,
  });

  static int _norm(int deg) {
    int n = deg % 360;
    return n < 0 ? n + 360 : n;
  }

  static String _dirLabel(int d) {
    switch (_norm(d)) {
      case 0: return 'N';
      case 45: return 'NE';
      case 90: return 'E';
      case 135: return 'SE';
      case 180: return 'S';
      case 225: return 'SW';
      case 270: return 'W';
      case 315: return 'NW';
      default: return '';
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerY = h / 2;

    final tickMinor = Paint()
      ..color = color.withValues(alpha: .5)
      ..strokeWidth = 1;

    final tickMajor = Paint()
      ..color = color.withValues(alpha: .85)
      ..strokeWidth = 1.3;

    final pxPerDeg = w / fov;
    final startDegD = heading - fov / 2.0;
    final endDegD = heading + fov / 2.0;

    final int start = startDegD.floor();
    final int end = endDegD.ceil();

    for (int deg = start; deg <= end; deg++) {
      if (deg % 5 != 0) continue;
      final double x = (deg - startDegD) * pxPerDeg;
      final int n = _norm(deg);

      double len = 8;
      Paint p = tickMinor;

      if (n % 15 == 0) len = 12;
      if (n % 30 == 0) { len = 16; p = tickMajor; }
      if (n % 90 == 0) { len = 18; p = tickMajor; }

      final y1 = centerY - len / 2;
      final y2 = centerY + len / 2;
      canvas.drawLine(Offset(x, y1), Offset(x, y2), p);

      String label = '';
      if (n % 45 == 0) {
        label = _dirLabel(n);
      } else if (n % 15 == 0) {
        label = '$n';
      }

      if (label.isNotEmpty) {
        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, centerY + len / 2 + 6));
      }
    }

    // Středový marker
    final cx = w / 2;

    // Glow efekt (rozmazaná modrá)
    final glow = Paint()
      ..color = markerColor.withValues(alpha: .4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx, centerY), 4, glow);

    // Hlavní ryska
    canvas.drawLine(
      Offset(cx, centerY - 10),
      Offset(cx, centerY + 10),
      Paint()
        ..color = Colors.white.withValues(alpha: .9)
        ..strokeWidth = 1.4,
    );

    // modrá tečka uprostřed
    canvas.drawCircle(
      Offset(cx, centerY),
      2.2,
      Paint()
        ..color = markerColor.withValues(alpha: .9)
        ..style = PaintingStyle.fill,
    );

    // Aktuální hodnota nad markerem
    final int centerDeg = _norm(heading.round());
    final tp = TextPainter(
      text: TextSpan(
        text: '$centerDeg°',
        style: (textStyle ?? const TextStyle()).copyWith(
          color: Colors.white.withValues(alpha: .95),
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(cx - tp.width / 2, centerY - 28));
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) =>
      old.heading != heading ||
      old.fov != fov ||
      old.color != color ||
      old.markerColor != markerColor ||
      old.textStyle != textStyle;
}
