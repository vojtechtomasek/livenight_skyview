import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/sky_view_provider.dart';
import '../../../models/sphere_star_data.dart';
import '../../../utils/sphere_projection.dart';
import '../../object_detail/object_detail_screen.dart';
import 'sky_view_painter.dart';

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
        star.elevation,
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
          showObjectDetailSheet(context, objectName: star.name);
          return;
        }
      }
    }
  }

  List<SphereStarData> _getStarsData() {
    return SphereStarData.getAllStars();
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
              onTapUp: _handleStarTap,
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