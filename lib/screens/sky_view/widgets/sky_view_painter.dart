import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/star_display.dart';
import '../../../utils/sphere_projection.dart';
import '../../../services/constellation_display_service.dart';

class SkyViewPainter extends CustomPainter {
  final double horizontalRotation;
  final double verticalRotation;
  final List<StarDisplay> stars;
  final List<ConstellationLine> constellations;

  SkyViewPainter(
    this.horizontalRotation,
    this.verticalRotation,
    this.stars,
    this.constellations,
  );

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawStars(canvas, size);
    _drawConstellations(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    const Color zenithColor = Color.fromARGB(255, 11, 30, 117);
    const Color skyHorizon = Color.fromARGB(255, 27, 16, 66);
    const Color groundHorizon = Color.fromARGB(255, 27, 16, 66);
    const Color nadirColor = Color.fromARGB(255, 30, 10, 47);

    const int azStep = 2; // Fine step for smoothness
    const int elStep = 2;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int el = -90; el < 90; el += elStep) {
      for (int az = 0; az < 360; az += azStep) {
        double midEl = el + elStep / 2.0;
        Color quadColor;

        double t = midEl.abs() / 90.0;

        double smoothT = math.pow(t, 0.6).toDouble();

        if (midEl >= 0) {
          quadColor = Color.lerp(skyHorizon, zenithColor, smoothT)!;
        } else {
          double groundT = math.pow(t, 0.5).toDouble();
          quadColor = Color.lerp(groundHorizon, nadirColor, groundT)!;
        }

        paint.color = quadColor;

        final p1 = projectSphereToScreen(
            az.toDouble(), el.toDouble(), center, radius, size,
            horizontalRotation, verticalRotation,
            cullOffScreen: false);
        final p2 = projectSphereToScreen(
            (az + azStep).toDouble(), el.toDouble(), center, radius, size,
            horizontalRotation, verticalRotation,
            cullOffScreen: false);
        final p3 = projectSphereToScreen((az + azStep).toDouble(),
            (el + elStep).toDouble(), center, radius, size,
            horizontalRotation, verticalRotation,
            cullOffScreen: false);
        final p4 = projectSphereToScreen(
            az.toDouble(), (el + elStep).toDouble(), center, radius, size,
            horizontalRotation, verticalRotation,
            cullOffScreen: false);

        if (p1 != null && p2 != null && p3 != null && p4 != null) {
          final path = Path()
            ..moveTo(p1.dx, p1.dy)
            ..lineTo(p2.dx, p2.dy)
            ..lineTo(p3.dx, p3.dy)
            ..lineTo(p4.dx, p4.dy)
            ..close();

          canvas.drawPath(path, paint);
        }
      }
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    for (final star in stars) {
      final projectedPos = projectSphereToScreen(
        star.azimuth,
        star.altitude,
        center,
        radius,
        size,
        horizontalRotation,
        verticalRotation,
      );

      // If the star is visible (not behind the horizon or behind us)
      if (projectedPos != null) {
        // Determine if this is a bright star based on magnitude
        final isBright = star.mag < 1.5;
        
        // Create paint for this star
        final starPaint = Paint()
          ..color = Colors.white.withOpacity(star.opacity)
          ..style = PaintingStyle.fill;
        
        // Add glow effect for brighter stars
        if (isBright) {
          starPaint.maskFilter = MaskFilter.blur(
            BlurStyle.normal, 
            star.size * 0.8,
          );
        }

        canvas.drawCircle(projectedPos, star.size, starPaint);
      }
    }
  }

  void _drawConstellations(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final constellationPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final line in constellations) {
      final projectedPoints = <Offset>[];

      // Convert all constellation points to screen coordinates
      for (final point in line.points) {
        final projected = projectSphereToScreen(
          point.azimuth,
          point.altitude,
          center,
          radius,
          size,
          horizontalRotation,
          verticalRotation,
        );
        if (projected != null) {
          projectedPoints.add(projected);
        }
      }

      // Draw lines between the projected points
      for (int i = 0; i < projectedPoints.length - 1; i++) {
        canvas.drawLine(
          projectedPoints[i],
          projectedPoints[i + 1],
          constellationPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SkyViewPainter oldDelegate) {
    return oldDelegate.horizontalRotation != horizontalRotation ||
        oldDelegate.verticalRotation != verticalRotation ||
        oldDelegate.stars != stars ||
        oldDelegate.constellations != constellations;
  }
}
