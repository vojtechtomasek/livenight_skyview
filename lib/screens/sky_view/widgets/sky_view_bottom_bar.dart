import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: LiquidGlass.withOwnLayer(
            settings: const LiquidGlassSettings(
              blur: 18.0,
              thickness: 15.0,
              refractiveIndex: 1.45,
              
              glassColor: Color(0x4410162D),
                
              lightIntensity: 1.3,
              ambientStrength: 0.35,
              
              saturation: 1.05,
            ),
            shape: const LiquidRoundedSuperellipse(
              borderRadius: 26,
            ),
            child: SizedBox(
              height: 64,
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
        ),
      ),
    );
  }
}
