import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/sky_view_provider.dart';

class SimpleSkyView extends StatefulWidget {
  final Function(ControlMode)? onControlModeChanged;
  final Function(VoidCallback)? registerToggleCallback;

  const SimpleSkyView({
    super.key,
    this.onControlModeChanged,
    this.registerToggleCallback,
  });

  @override
  State<SimpleSkyView> createState() => _SimpleSkyViewState();
}

class _SimpleSkyViewState extends State<SimpleSkyView> {
  @override
  void initState() {
    super.initState();
    // Register the toggle function with parent
    final provider = context.read<SkyViewProvider>();
    widget.registerToggleCallback?.call(_toggleControlMode);

    // Listen to control mode changes
    provider.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    context.read<SkyViewProvider>().removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    final provider = context.read<SkyViewProvider>();
    widget.onControlModeChanged?.call(provider.controlMode);
  }

  void _toggleControlMode() {
    context.read<SkyViewProvider>().toggleControlMode();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    context.read<SkyViewProvider>().updateRotationFromTouch(
          details.delta.dx,
          details.delta.dy,
        );
  }

  void _onPointerMove(PointerMoveEvent event) {
    final provider = context.read<SkyViewProvider>();
    if (provider.controlMode == ControlMode.touch) {
      provider.updateRotationFromTouch(
        event.delta.dx,
        event.delta.dy,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SkyViewProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.black,
          child: Listener(
            onPointerMove: _onPointerMove,
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: CustomPaint(
                painter: SkyViewPainter(
                  provider.horizontalRotation,
                  provider.verticalRotation,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        );
      },
    );
  }
}

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

        final p1 = _projectSphereToScreen(
            az.toDouble(), el.toDouble(), center, radius, size,
            cullOffScreen: false);
        final p2 = _projectSphereToScreen(
            (az + azStep).toDouble(), el.toDouble(), center, radius, size,
            cullOffScreen: false);
        final p3 = _projectSphereToScreen((az + azStep).toDouble(),
            (el + elStep).toDouble(), center, radius, size,
            cullOffScreen: false);
        final p4 = _projectSphereToScreen(
            az.toDouble(), (el + elStep).toDouble(), center, radius, size,
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
    final stars = <SphereStarData>[
      // Jasné hvězdy v různých směrech (severní polokoule)
      SphereStarData(0, 50, 3.0, true), // Sever - Polárka
      SphereStarData(90, 25, 2.5, true), // Východ
      SphereStarData(180, 30, 2.8, true), // Jih
      SphereStarData(270, 20, 2.2, true), // Západ

      // Jasné hvězdy na jižní polokouli
      SphereStarData(45, -30, 2.4, true), // Jihovýchod dolní
      SphereStarData(135, -25, 2.6, true), // Jihozápad dolní
      SphereStarData(225, -35, 2.3, true), // Severozápad dolní
      SphereStarData(315, -20, 2.5, true), // Severovýchod dolní

      // Velký vůz (severní část oblohy)
      SphereStarData(195, 55, 2.0, false),
      SphereStarData(205, 58, 1.8, false),
      SphereStarData(215, 60, 1.9, false),
      SphereStarData(225, 62, 1.7, false),
      SphereStarData(235, 60, 1.8, false),
      SphereStarData(245, 57, 1.6, false),
      SphereStarData(255, 54, 1.7, false),

      // Orion (zimní souhvězdí)
      SphereStarData(80, 5, 2.1, false),
      SphereStarData(85, 0, 1.9, false),
      SphereStarData(90, -2, 2.0, false),
      SphereStarData(95, 2, 1.8, false),
      SphereStarData(100, 8, 1.7, false),

      // Kassiopea (W tvar)
      SphereStarData(10, 65, 1.8, false),
      SphereStarData(20, 68, 1.6, false),
      SphereStarData(30, 65, 1.7, false),
      SphereStarData(40, 68, 1.5, false),
      SphereStarData(50, 65, 1.6, false),

      // Hvězdy severní polokoule (vysoká elevace)
      SphereStarData(60, 70, 1.4, false),
      SphereStarData(120, 75, 1.3, false),
      SphereStarData(180, 72, 1.5, false),
      SphereStarData(240, 68, 1.2, false),
      SphereStarData(300, 71, 1.4, false),

      // Střední pás oblohy (kolem rovníku)
      SphereStarData(30, 35, 1.5, false),
      SphereStarData(60, 25, 1.3, false),
      SphereStarData(120, 40, 1.4, false),
      SphereStarData(150, 30, 1.2, false),
      SphereStarData(210, 35, 1.6, false),
      SphereStarData(270, 32, 1.3, false),
      SphereStarData(330, 28, 1.4, false),

      // Hvězdy jižní polokoule (negativní elevace)
      SphereStarData(0, -40, 1.4, false), // Jih dole
      SphereStarData(60, -50, 1.3, false),
      SphereStarData(120, -45, 1.5, false),
      SphereStarData(180, -60, 1.2, false), // Nejjižnější bod
      SphereStarData(240, -35, 1.4, false),
      SphereStarData(300, -55, 1.3, false),

      // Další hvězdy na jižní polokouli
      SphereStarData(15, -25, 1.2, false),
      SphereStarData(75, -30, 1.1, false),
      SphereStarData(135, -20, 1.3, false),
      SphereStarData(195, -45, 1.0, false),
      SphereStarData(255, -40, 1.2, false),
      SphereStarData(315, -35, 1.1, false),

      // Nízké elevace (blízko horizontu)
      SphereStarData(45, 10, 1.3, false),
      SphereStarData(135, 15, 1.5, false),
      SphereStarData(225, 8, 1.3, false),
      SphereStarData(315, 12, 1.4, false),

      // Nízké elevace na druhé straně (záporné)
      SphereStarData(45, -10, 1.2, false),
      SphereStarData(135, -15, 1.4, false),
      SphereStarData(225, -8, 1.2, false),
      SphereStarData(315, -12, 1.3, false),

      // Slabé hvězdy rozmístěné po celé sféře
      SphereStarData(15, 20, 1.0, false),
      SphereStarData(75, 35, 1.1, false),
      SphereStarData(165, 45, 1.0, false),
      SphereStarData(255, 30, 1.2, false),
      SphereStarData(345, 40, 1.0, false),

      // Slabé hvězdy na jižní polokouli
      SphereStarData(15, -20, 0.9, false),
      SphereStarData(75, -35, 1.0, false),
      SphereStarData(165, -45, 0.9, false),
      SphereStarData(255, -30, 1.1, false),
      SphereStarData(345, -40, 0.9, false),

      // Dodatečné hvězdy pro hustší oblohu na obou polokoulích
      SphereStarData(52, 42, 1.1, false),
      SphereStarData(108, 18, 1.0, false),
      SphereStarData(172, 52, 1.2, false),
      SphereStarData(238, 38, 1.0, false),
      SphereStarData(295, 55, 1.1, false),
      SphereStarData(358, 48, 1.0, false),

      // Zrcadlové hvězdy na jižní polokouli
      SphereStarData(52, -42, 1.0, false),
      SphereStarData(108, -18, 0.9, false),
      SphereStarData(172, -52, 1.1, false),
      SphereStarData(238, -38, 0.9, false),
      SphereStarData(295, -55, 1.0, false),
      SphereStarData(358, -48, 0.9, false),

      // Hvězdy velmi blízko "spodního pólu" (elevace -80°)
      SphereStarData(0, -80, 1.1, false),
      SphereStarData(90, -85, 1.0, false),
      SphereStarData(180, -80, 1.2, false),
      SphereStarData(270, -85, 1.0, false),
    ];

    for (final star in stars) {
      final projectedPos = _projectSphereToScreen(
        star.azimuth,
        star.elevation,
        center,
        radius,
        size,
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

  Offset? _projectSphereToScreen(
    double azimuthDeg,
    double elevationDeg,
    Offset center,
    double radius,
    Size size, {
    bool cullOffScreen = true,
  }) {
    // Převod na radiány
    final azimuth = azimuthDeg * math.pi / 180;
    final elevation = elevationDeg * math.pi / 180;

    // 3D kartézské souřadnice na sféře (originální pozice hvězdy)
    double x = math.cos(elevation) * math.sin(azimuth);
    double y = math.sin(elevation);
    double z = math.cos(elevation) * math.cos(azimuth);

    // Rotace kolem Y osy (horizontální otáčení)
    final cosH = math.cos(-horizontalRotation);
    final sinH = math.sin(-horizontalRotation);
    final x1 = x * cosH - z * sinH;
    final z1 = x * sinH + z * cosH;
    x = x1;
    z = z1;

    // Rotace kolem X osy (vertikální otáčení)
    final cosV = math.cos(-verticalRotation);
    final sinV = math.sin(-verticalRotation);
    final y1 = y * cosV - z * sinV;
    final z2 = y * sinV + z * cosV;
    y = y1;
    z = z2;

    // Perspektivní projekce - pouze hvězdy před námi jsou viditelné
    if (z <= 0) return null;

    // FOV (field of view) - úhel záběru kamery
    const fov = math.pi / 3; // 60 stupňů
    final focalLength = 1.0 / math.tan(fov / 2);

    // Perspektivní projekce na obrazovku
    final projectedX = (x / z) * focalLength;
    final projectedY = (y / z) * focalLength;

    // Převod na pixely obrazovky
    final scale = math.min(size.width, size.height) * 0.5;
    final screenX = center.dx + (projectedX * scale);
    final screenY = center.dy - (projectedY * scale); // Y je obrácené

    // Kontrola, zda je hvězda na obrazovce
    if (cullOffScreen) {
      if (screenX < -100 ||
          screenX > size.width + 100 ||
          screenY < -100 ||
          screenY > size.height + 100) {
        return null;
      }
    }

    return Offset(screenX, screenY);
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
        final projected = _projectSphereToScreen(
          point[0].toDouble(),
          point[1].toDouble(),
          center,
          radius,
          size,
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

class SphereStarData {
  final double azimuth; // Azimut ve stupních (0–360)
  final double elevation; // Elevace ve stupních (-90 až +90)
  final double size; // Velikost hvězdy
  final bool isBright; // Zda je hvězda jasná

  SphereStarData(this.azimuth, this.elevation, this.size, this.isBright);
}
