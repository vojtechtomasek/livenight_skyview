import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../models/star_display.dart';
import '../../../providers/sky_view_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../services/star_display_service.dart';
import '../../../services/constellation_display_service.dart';
import '../../../utils/sphere_projection.dart';
import '../../object_detail/object_detail_screen.dart';
import 'sky_view_painter.dart';

class SimpleSkyView extends StatefulWidget {
  const SimpleSkyView({super.key});

  @override
  State<SimpleSkyView> createState() => _SimpleSkyViewState();
}

class _SimpleSkyViewState extends State<SimpleSkyView> {
  double _baseZoomLevel = 1.0;
  Offset _lastFocalPoint = Offset.zero;
  int _pointerCount = 0;
  
  List<StarDisplay>? _cachedStars;
  List<ConstellationLine>? _cachedConstellations;
  DateTime? _lastUpdate;

  void _onScaleStart(ScaleStartDetails details) {
    final provider = context.read<SkyViewProvider>();
    if (provider.controlMode != ControlMode.touch) return;
    
    _baseZoomLevel = provider.zoomLevel;
    _lastFocalPoint = details.focalPoint;
    _pointerCount = details.pointerCount;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final provider = context.read<SkyViewProvider>();
    if (provider.controlMode != ControlMode.touch) return;

    // Two fingers = zoom
    if (details.pointerCount >= 2) {
      final newZoom = _baseZoomLevel * details.scale;
      provider.setZoom(newZoom);
    } 
    // One finger = pan
    else if (details.pointerCount == 1) {
      final delta = details.focalPoint - _lastFocalPoint;
      provider.updateRotationFromTouch(delta.dx, delta.dy);
    }

    _lastFocalPoint = details.focalPoint;
    _pointerCount = details.pointerCount;
  }

  void _handleStarTap(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = details.localPosition;
    final size = box.size;
    
    final provider = context.read<SkyViewProvider>();
    final stars = _getStarsData();
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * provider.zoomLevel;
    
    // Find tapped star
    for (final star in stars) {
      final projectedPos = projectSphereToScreen(
        star.azimuth,
        star.altitude,
        center,
        radius,
        size,
        provider.horizontalRotation,
        provider.verticalRotation,
      );
      
      if (projectedPos != null) {
        final distance = (projectedPos - localPosition).distance;
        if (distance < 30) {
          // Star tapped!
          showObjectDetailSheet(context, objectName: 'HIP ${star.hip}');
          return;
        }
      }
    }
  }

  List<StarDisplay> _getStarsData() {
    final now = DateTime.now();
    if (_cachedStars != null && _lastUpdate != null && 
        now.difference(_lastUpdate!).inSeconds < 1) {
      return _cachedStars!;
    }
    
    final locationProvider = context.read<LocationProvider>();
    final latitude = locationProvider.latitude ?? 50.0; // Default latitude
    final longitude = locationProvider.longitude ?? 14.0; // Default longitude
    final utcNow = now.toUtc();
    
    _cachedStars = StarDisplayService().getDisplayStars(
      latitude: latitude,
      longitude: longitude,
      dateTime: utcNow,
    );
    _lastUpdate = now;
    return _cachedStars!;
  }

  List<ConstellationLine> _getConstellationData() {
    if (_cachedConstellations != null) {
      return _cachedConstellations!;
    }
    
    final locationProvider = context.read<LocationProvider>();
    final latitude = locationProvider.latitude ?? 50.0;
    final longitude = locationProvider.longitude ?? 14.0;
    final now = DateTime.now().toUtc();
    
    _cachedConstellations = ConstellationDisplayService().getConstellationLines(
      latitude: latitude,
      longitude: longitude,
      dateTime: now,
    );
    return _cachedConstellations!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SkyViewProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.black,
          child: Listener(
            onPointerDown: (event) {},
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: provider.controlMode == ControlMode.touch ? _onScaleStart : null,
              onScaleUpdate: provider.controlMode == ControlMode.touch ? _onScaleUpdate : null,
              onScaleEnd: provider.controlMode == ControlMode.touch ? (details) {} : null,
              onTapUp: _handleStarTap,
              child: CustomPaint(
                painter: SkyViewPainter(
                  provider.horizontalRotation,
                  provider.verticalRotation,
                  provider.zoomLevel,
                  _getStarsData(),
                  _getConstellationData(),
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