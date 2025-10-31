import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassProvider extends ChangeNotifier {
  double? _heading;
  StreamSubscription? _sub;

  double _alpha = 0.25;

  double? get heading => _heading;

  void setSmoothing(double alpha) {
    _alpha = alpha.clamp(0.05, 0.9);
  }

  Future<void> start() async {
    await _sub?.cancel();
    _sub = FlutterCompass.events?.listen((event) {
      final raw = event.heading;
      if (raw == null) return;

      final h = _normalize(raw);

      if (_heading == null) {
        _heading = h;
      } else {
        _heading = _smoothAngle(_heading!, h, _alpha);
      }
      notifyListeners();
    });
  }

  void stop() async {
    await _sub?.cancel();
    _sub = null;
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
