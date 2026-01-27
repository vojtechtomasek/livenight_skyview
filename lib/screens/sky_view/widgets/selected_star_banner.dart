import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../models/star.dart';
import '../../../services/star_names_service.dart';

class SelectedStarBanner extends StatelessWidget {
  final Star star;
  final VoidCallback onClear;

  const SelectedStarBanner({
    super.key,
    required this.star,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    // Get common name from database
    final commonName = StarNamesService().getNameByHip(star.hip);
    
    // Build display name
    final displayName = commonName ?? star.commonName ?? star.mainId ?? 'HIP ${star.hip}';
    
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 70, bottom: 16),
      child: LiquidGlass.withOwnLayer(
        settings: const LiquidGlassSettings(
          blur: 2.0,
          thickness: 3.0,
          refractiveIndex: 1.2,
          glassColor: Color(0x04000000),
          lightIntensity: 1.0,
          ambientStrength: 0.2,
          saturation: 1.0,
        ),
        shape: const LiquidRoundedSuperellipse(
          borderRadius: 16,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.star_fill,
                color: CupertinoColors.systemYellow,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: CupertinoColors.black,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 32,
                onPressed: onClear,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: CupertinoColors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
