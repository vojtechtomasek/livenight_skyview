import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:livenight_skyview/models/star.dart';
import 'package:livenight_skyview/api/get_star_detail.dart';
import 'package:livenight_skyview/api/get_star_description.dart';
import 'widgets/object_header.dart';
import 'widgets/object_basic_info.dart';
import 'widgets/object_description.dart';

Future<void> showObjectDetailSheet(BuildContext context, {required Star star}) {
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
          _ObjectDetailDraggableSheet(star: star),
        ],
      );
    },
  );
}

class _ObjectDetailDraggableSheet extends StatefulWidget {
  final Star star;
  const _ObjectDetailDraggableSheet({required this.star});

  @override
  State<_ObjectDetailDraggableSheet> createState() => _ObjectDetailDraggableSheetState();
}

class _ObjectDetailDraggableSheetState extends State<_ObjectDetailDraggableSheet> {
  Star? _detailedStar;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStarDetail();
  }

  Future<void> _fetchStarDetail() async {
    try {
      // First fetch SIMBAD detail
      final detailService = StarDetailService();
      final detailedStar = await detailService.fetchStarDetail(baseStar: widget.star);
      
      // Then fetch Wikipedia description and image
      final descriptionService = StarDescriptionService();
      final enrichedStar = await descriptionService.fetchDescription(baseStar: detailedStar);
      
      if (mounted) {
        setState(() {
          _detailedStar = enrichedStar;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _detailedStar = widget.star; // Fallback to base star
        });
      }
    }
  }

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
                      child: _isLoading
                          ? const Center(
                              child: CupertinoActivityIndicator(
                                color: CupertinoColors.white,
                              ),
                            )
                          : SingleChildScrollView(
                              controller: controller,
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  ObjectHeader(star: _detailedStar ?? widget.star),
                                  const SizedBox(height: 24),
                                  ObjectBasicInfo(star: _detailedStar ?? widget.star),
                                  const SizedBox(height: 24),
                                  ObjectDescription(star: _detailedStar ?? widget.star),
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