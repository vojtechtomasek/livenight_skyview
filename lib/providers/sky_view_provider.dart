import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../services/sensor_orientation_service.dart';

enum ControlMode { touch, sensor }

class SkyViewProvider extends ChangeNotifier {
  double _horizontalRotation = 0.0;
  double _verticalRotation = 0.0;
  ControlMode _controlMode = ControlMode.touch;

  // Smoothing for sensor data
  double _targetHorizontalRotation = 0.0;
  double _targetVerticalRotation = 0.0;
  static const double _smoothingFactor = 0.15;

  final SensorOrientationService _sensorService = SensorOrientationService();

  // Rotation limits
  static const double maxVerticalRotation = 3.14159265359 / 2; // π/2
  static const double minVerticalRotation = -3.14159265359 / 2; // -π/2

  double get horizontalRotation => _horizontalRotation;
  double get verticalRotation => _verticalRotation;
  ControlMode get controlMode => _controlMode;

  SkyViewProvider() {
    _sensorService.onOrientationUpdate = _handleSensorUpdate;
    _sensorService.startListening();
  }

  void toggleControlMode() {
    if (_controlMode == ControlMode.touch) {
      _controlMode = ControlMode.sensor;
      // Initialize target rotations to current values for smooth transition
      _targetHorizontalRotation = _horizontalRotation;
      _targetVerticalRotation = _verticalRotation;
    } else {
      _controlMode = ControlMode.touch;
    }
    notifyListeners();
  }

  void updateRotationFromTouch(double deltaX, double deltaY) {
    if (_controlMode != ControlMode.touch) return;

    _horizontalRotation += deltaX * 0.005;
    _verticalRotation -= deltaY * 0.005;
    _verticalRotation = _verticalRotation.clamp(
      minVerticalRotation,
      maxVerticalRotation,
    );
    notifyListeners();
  }

  void _handleSensorUpdate(double azimuth, double pitch) {
    if (_controlMode != ControlMode.sensor) return;

    // Invert the axes for correct movement direction
    _targetHorizontalRotation = -azimuth;
    _targetVerticalRotation = -pitch.clamp(
      minVerticalRotation,
      maxVerticalRotation,
    );

    // Apply smoothing with shortest angle distance for horizontal rotation
    // Calculate horizontal difference with wrap-around handling
    double horizontalDiff = _targetHorizontalRotation - _horizontalRotation;
    if (horizontalDiff > math.pi) {
      horizontalDiff -= 2 * math.pi;
    } else if (horizontalDiff < -math.pi) {
      horizontalDiff += 2 * math.pi;
    }
    _horizontalRotation += horizontalDiff * _smoothingFactor;

    // Apply smoothing for vertical rotation
    _verticalRotation +=
        (_targetVerticalRotation - _verticalRotation) * _smoothingFactor;

    notifyListeners();
  }

  @override
  void dispose() {
    _sensorService.dispose();
    super.dispose();
  }
}
