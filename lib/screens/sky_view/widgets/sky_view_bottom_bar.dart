import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../providers/conpass_provider.dart';
import 'compass_widget.dart';
class SkyViewBottomBar extends StatelessWidget {
  const SkyViewBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          color: CupertinoColors.black.withValues(alpha: .30),
          child: Consumer<CompassProvider>(
            builder: (_, compass, __) {
              final heading = compass.heading ?? 0.0;
              return CompassWidget(
                heading: heading,
                fovDegrees: 120,
                color: CupertinoColors.white,
                markerColor: const Color(0xFF8AB4F8),
              );
            },
          ),
        ),
      ),
    );
  }
}
