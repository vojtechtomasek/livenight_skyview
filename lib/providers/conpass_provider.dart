import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CompassProvider extends ChangeNotifier {
  double? _heading;
  StreamSubscription? _compassSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  double _alpha = 0.25;
  
  // Store device orientation
  double _accelZ = 0.0;
  double? _previousRawHeading;
  bool _isFlipped = false;

  double? get heading => _heading;

  void setSmoothing(double alpha) {
    _alpha = alpha.clamp(0.05, 0.9);
  }

  Future<void> start() async {
    await _compassSub?.cancel();
    await _accelSub?.cancel();
    
    // Listen to accelerometer to detect screen orientation
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      // Store Z value - positive when screen faces up, negative when faces down
      _accelZ = event.z;
    });
    
    _compassSub = FlutterCompass.events?.listen((event) {
      final raw = event.heading;
      if (raw == null) return;

      var h = _normalize(raw);
      
      // Detect sudden jumps in heading (gimbal lock flip detection)
      if (_previousRawHeading != null) {
        final rawDiff = (h - _previousRawHeading!).abs();
        
        // If heading suddenly jumped ~180 degrees (between 140-220 degrees)
        // it's likely a gimbal lock flip
        if (rawDiff > 140 && rawDiff < 220) {
          _isFlipped = !_isFlipped;
        }
      }
      
      _previousRawHeading = h;
      
      // Apply flip correction
      if (_isFlipped) {
        h = _normalize(h + 180);
      }
      
      // Reset flip state when phone is flat (Z > 5, strong gravity pointing down)
      if (_accelZ > 5.0) {
        _isFlipped = false;
      }

      if (_heading == null) {
        _heading = h;
      } else {
        _heading = _smoothAngle(_heading!, h, _alpha);
      }
      notifyListeners();
    });
  }

  void stop() async {
    await _compassSub?.cancel();
    await _accelSub?.cancel();
    _compassSub = null;
    _accelSub = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  double _normalize(double deg) {
    var x = deg % 360.0;
    if (x < 0) x += 360.0;
    return x;
  }

  double _smoothAngle(double prev, double next, double alpha) {
    final p = prev * math.pi / 180.0;
    final n = next * math.pi / 180.0;

    final vx = math.cos(p) * (1 - alpha) + math.cos(n) * alpha;
    final vy = math.sin(p) * (1 - alpha) + math.sin(n) * alpha;
    final ang = math.atan2(vy, vx) * 180.0 / math.pi;

    return _normalize(ang);
  }
}
