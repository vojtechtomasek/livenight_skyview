import 'dart:math' as math;
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorOrientationService {
  // Sensor subscriptions
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  // Accumulated rotation from gyroscope
  double _horizontalRotation = 0.0;
  double _verticalRotation = 0.0;

  // Timestamp for gyroscope integration
  DateTime? _lastGyroUpdate;

  // Accelerometer data for gravity direction
  double _accelerometerX = 0.0;
  double _accelerometerY = 0.0;
  double _accelerometerZ = 0.0;

  // Magnetometer data for absolute heading
  double _magnetometerX = 0.0;
  double _magnetometerY = 0.0;
  double _magnetometerZ = 0.0;

  // Calibration offset for initial heading
  double? _initialHeadingOffset;
  bool _isCalibrating = true;

  // Callback for orientation updates
  Function(double horizontalRotation, double verticalRotation)?
      onOrientationUpdate;

  void startListening() {
    _lastGyroUpdate = DateTime.now();
    _isCalibrating = true;
    _initialHeadingOffset = null;

    // Gyroscope for smooth rotation tracking
    _gyroscopeSubscription = gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 20),
    ).listen((GyroscopeEvent event) {
      _handleGyroscopeUpdate(event);
    });

    // Accelerometer for gravity direction (to prevent drift in vertical axis)
    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((AccelerometerEvent event) {
      _accelerometerX = event.x;
      _accelerometerY = event.y;
      _accelerometerZ = event.z;
      _correctVerticalDrift();
    });

    // Magnetometer for absolute heading (to prevent drift in horizontal axis)
    _magnetometerSubscription = magnetometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((MagnetometerEvent event) {
      _magnetometerX = event.x;
      _magnetometerY = event.y;
      _magnetometerZ = event.z;
      _correctHorizontalDrift();
    });
  }

  void stopListening() {
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _magnetometerSubscription?.cancel();
  }

  void _handleGyroscopeUpdate(GyroscopeEvent event) {
    final now = DateTime.now();
    if (_lastGyroUpdate == null) {
      _lastGyroUpdate = now;
      return;
    }

    // Calculate time delta in seconds
    final dt = (now.difference(_lastGyroUpdate!).inMicroseconds) / 1000000.0;
    _lastGyroUpdate = now;

    if (dt > 0.1) return; // Skip large time gaps

    // Gyroscope values are in radians per second
    // For portrait mode: x = pitch, y = yaw (horizontal), z = roll
    final pitchRate = event.x; // Tilting phone forward/backward
    final yawRate = event.y; // Rotating phone left/right (horizontal)

    // Integrate rotation rates to get angles
    // Note: We use yaw for horizontal and pitch for vertical
    _horizontalRotation -= yawRate * dt; // Negative for intuitive direction
    _verticalRotation += pitchRate * dt;

    // Clamp vertical rotation to prevent looking too far up or down
    _verticalRotation = _verticalRotation.clamp(-math.pi / 2, math.pi / 2);

    // Normalize horizontal rotation to [0, 2π]
    _horizontalRotation = _horizontalRotation % (2 * math.pi);

    onOrientationUpdate?.call(_horizontalRotation, _verticalRotation);
  }

  void _correctVerticalDrift() {
    // Use accelerometer to correct vertical drift
    final norm = math.sqrt(
      _accelerometerX * _accelerometerX +
          _accelerometerY * _accelerometerY +
          _accelerometerZ * _accelerometerZ,
    );

    if (norm < 0.1) return;

    final ax = _accelerometerX / norm;
    final ay = _accelerometerY / norm;
    final az = _accelerometerZ / norm;

    // Calculate actual pitch from gravity
    final actualPitch = math.atan2(az, math.sqrt(ax * ax + ay * ay));

    // Apply small correction to prevent drift
    const correctionFactor = 0.02;
    _verticalRotation += (actualPitch - _verticalRotation) * correctionFactor;
    _verticalRotation = _verticalRotation.clamp(-math.pi / 2, math.pi / 2);
  }

  void _correctHorizontalDrift() {
    // Use magnetometer to correct horizontal drift
    final norm = math.sqrt(
      _accelerometerX * _accelerometerX +
          _accelerometerY * _accelerometerY +
          _accelerometerZ * _accelerometerZ,
    );

    if (norm < 0.1) return;

    final ax = _accelerometerX / norm;
    final ay = _accelerometerY / norm;
    final az = _accelerometerZ / norm;

    final pitch = math.atan2(az, math.sqrt(ax * ax + ay * ay));
    final roll = math.atan2(ax, -ay);

    // Tilt-compensated magnetometer reading
    final sinPitch = math.sin(pitch);
    final cosPitch = math.cos(pitch);
    final sinRoll = math.sin(roll);
    final cosRoll = math.cos(roll);

    final hx = _magnetometerX * cosPitch + _magnetometerZ * sinPitch;
    final hy = _magnetometerY;
    final cx = hx * cosRoll + hy * sinRoll;
    final cy = -hx * sinRoll + hy * cosRoll;

    final actualHeading = math.atan2(-cx, cy);

    // Calibrate initial offset on first good reading
    if (_isCalibrating && actualHeading.isFinite) {
      _initialHeadingOffset = actualHeading - _horizontalRotation;
      _isCalibrating = false;
    }

    if (_initialHeadingOffset != null && actualHeading.isFinite) {
      final targetHeading = actualHeading - _initialHeadingOffset!;

      // Handle angle wrapping for smooth correction
      double diff = targetHeading - _horizontalRotation;
      if (diff > math.pi) {
        diff -= 2 * math.pi;
      } else if (diff < -math.pi) {
        diff += 2 * math.pi;
      }

      // Apply small correction to prevent drift while allowing smooth rotation
      const correctionFactor = 0.01;
      _horizontalRotation += diff * correctionFactor;
      _horizontalRotation = _horizontalRotation % (2 * math.pi);
    }
  }

  void dispose() {
    stopListening();
    onOrientationUpdate = null;
  }
}
