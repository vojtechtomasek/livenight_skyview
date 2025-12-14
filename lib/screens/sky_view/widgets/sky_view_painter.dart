import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/sphere_star_data.dart';
import '../../../utils/sphere_projection.dart';

class SkyViewPainter extends CustomPainter {
  final double horizontalRotation;
  final double verticalRotation;

  SkyViewPainter(this.horizontalRotation, this.verticalRotation);

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

    const int azStep = 2; // Jemný krok pro hladkost
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

    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dimStarPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final brightStarPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Definice hvězd po celé sféře - pozitivní i negativní elevace
    final stars = SphereStarData.getAllStars();

    for (final star in stars) {
      final projectedPos = projectSphereToScreen(
        star.azimuth,
        star.elevation,
        center,
        radius,
        size,
        horizontalRotation,
        verticalRotation,
      );

      // Pokud je hvězda viditelná (není za horizontem nebo za námi)
      if (projectedPos != null) {
        final paint = star.isBright
            ? brightStarPaint
            : (star.size > 1.5 ? starPaint : dimStarPaint);

        canvas.drawCircle(projectedPos, star.size, paint);
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

    final constellations = [
      [
        [195, 55],
        [205, 58],
        [215, 60],
        [225, 62],
        [235, 60],
        [245, 57],
        [255, 54],
      ],
      [
        [80, 5],
        [85, 0],
        [90, -2],
        [95, 2],
        [100, 8],
      ],
      [
        [10, 65],
        [20, 68],
        [30, 65],
        [40, 68],
        [50, 65],
      ],
      [
        [190, -60],
        [185, -55],
        [195, -65],
        [200, -50],
      ],
      [
        [135, -25],
        [155, -30],
        [145, -45],
      ],
      [
        [270, -35],
        [280, -40],
        [290, -30],
      ],
      [
        [45, -40],
        [60, -40],
        [60, -55],
        [45, -55],
        [45, -40],
      ],
      [
        [180, 30],
        [200, 25],
        [160, 20],
      ],
      [
        [270, 20],
        [280, 25],
        [290, 22],
      ],
    ];

    for (final constellation in constellations) {
      final projectedPoints = <Offset>[];

      // Převod všech bodů souhvězdí na obrazovkové souřadnice
      for (final point in constellation) {
        final projected = projectSphereToScreen(
          point[0].toDouble(),
          point[1].toDouble(),
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

      // Kreslení čar mezi body souhvězdí
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
        oldDelegate.verticalRotation != verticalRotation;
  }
}
