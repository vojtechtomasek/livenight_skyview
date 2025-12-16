import 'dart:math' as math;
import 'package:flutter/material.dart';

Offset? projectSphereToScreen(
  double azimuthDeg,
  double elevationDeg,
  Offset center,
  double radius,
  Size size,
  double horizontalRotation,
  double verticalRotation, {
  bool cullOffScreen = true,
}) {
  // Convert to radians
  final azimuth = azimuthDeg * math.pi / 180;
  final elevation = elevationDeg * math.pi / 180;

  // 3D Cartesian coordinates on sphere (original star position)
  double x = math.cos(elevation) * math.sin(azimuth);
  double y = math.sin(elevation);
  double z = math.cos(elevation) * math.cos(azimuth);

  // Rotation around Y axis (horizontal rotation)
  final cosH = math.cos(-horizontalRotation);
  final sinH = math.sin(-horizontalRotation);
  final x1 = x * cosH - z * sinH;
  final z1 = x * sinH + z * cosH;
  x = x1;
  z = z1;

  // Rotation around X axis (vertical rotation)
  final cosV = math.cos(-verticalRotation);
  final sinV = math.sin(-verticalRotation);
  final y1 = y * cosV - z * sinV;
  final z2 = y * sinV + z * cosV;
  y = y1;
  z = z2;

  // Perspective projection - only stars in front of us are visible
  if (z <= 0) return null;

  // FOV (field of view) - camera viewing angle
  const fov = math.pi / 3;
  final focalLength = 1.0 / math.tan(fov / 2);

  // Perspective projection to screen
  final projectedX = (x / z) * focalLength;
  final projectedY = (y / z) * focalLength;

  // Convert to screen pixels
  final scale = math.min(size.width, size.height) * 0.5;
  final screenX = center.dx + (projectedX * scale);
  final screenY = center.dy - (projectedY * scale);

  // Check if star is on screen
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
