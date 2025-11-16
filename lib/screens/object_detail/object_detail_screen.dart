import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'widgets/object_header.dart';
import 'widgets/object_basic_info.dart';
import 'widgets/object_description.dart';

Future<void> showObjectDetailSheet(BuildContext context, {String? objectName}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (ctx) {
      return Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(ctx).pop(),
            child: Container(color: CupertinoColors.transparent),
          ),
          _ObjectDetailDraggableSheet(objectName: objectName),
        ],
      );
    },
  );
}

class _ObjectDetailDraggableSheet extends StatelessWidget {
  final String? objectName;
  const _ObjectDetailDraggableSheet({this.objectName});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Stack(
          children: [
            LiquidGlassLayer(
              settings: const LiquidGlassSettings(
                thickness: 25,
                blur: 20,
                glassColor: Color(0x400A0F2C),
                refractiveIndex: 1.5,
                lightIntensity: 0.8,
              ),
              child: LiquidGlass(
                shape: const LiquidRoundedSuperellipse(
                  borderRadius: 32,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            ObjectHeader(),
                            SizedBox(height: 24),
                            ObjectBasicInfo(),
                            SizedBox(height: 24),
                            ObjectDescription(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 50,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x000A0F2C),
                      Color(0xFF0A0F2C),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}