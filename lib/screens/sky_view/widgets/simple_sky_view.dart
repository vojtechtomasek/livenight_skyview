import 'dart:math' as math;
import 'package:flutter/material.dart';
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

  void _onPanUpdate(DragUpdateDetails details) {
    context.read<SkyViewProvider>().updateRotationFromTouch(
          details.delta.dx,
          details.delta.dy,
        );
  }

  void _handleStarTap(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = details.localPosition;
    final size = box.size;
    
    final provider = context.read<SkyViewProvider>();
    final stars = _getStarsData();
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
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
    final locationProvider = context.read<LocationProvider>();
    final latitude = locationProvider.latitude ?? 50.0; // Default latitude
    final longitude = locationProvider.longitude ?? 14.0; // Default longitude
    final now = DateTime.now().toUtc();
    
    return StarDisplayService().getDisplayStars(
      latitude: latitude,
      longitude: longitude,
      dateTime: now,
    );
  }

  List<ConstellationLine> _getConstellationData() {
    final locationProvider = context.read<LocationProvider>();
    final latitude = locationProvider.latitude ?? 50.0;
    final longitude = locationProvider.longitude ?? 14.0;
    final now = DateTime.now().toUtc();
    
    return ConstellationDisplayService().getConstellationLines(
      latitude: latitude,
      longitude: longitude,
      dateTime: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SkyViewProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.black,
          child: GestureDetector(
            onPanUpdate: provider.controlMode == ControlMode.touch ? _onPanUpdate : null,
            onTapUp: _handleStarTap,
            child: CustomPaint(
              painter: SkyViewPainter(
                provider.horizontalRotation,
                provider.verticalRotation,
                _getStarsData(),
                _getConstellationData(),
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}