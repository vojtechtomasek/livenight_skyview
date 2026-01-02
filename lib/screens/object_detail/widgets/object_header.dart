import 'package:flutter/cupertino.dart';
import 'package:livenight_skyview/models/star.dart';
import 'package:livenight_skyview/services/constellation_catalog_service.dart';

class ObjectHeader extends StatelessWidget {
  final Star star;
  const ObjectHeader({super.key, required this.star});

  String _getConstellationInfo() {
    // First try to get from star's constellation references
    if (star.constellations.isNotEmpty) {
      final ref = star.constellations.first;
      if (ref.nameEnglish != null) {
        return '${ref.iau} • ${ref.nameEnglish}';
      }
      return ref.iau;
    }
    
    // Otherwise, look it up in the constellation catalog
    final constellations = ConstellationCatalogService().getConstellationsForStar(star.hip);
    if (constellations.isNotEmpty) {
      final constellation = constellations.first;
      if (constellation.nameEnglish != null) {
        return '${constellation.iau} • ${constellation.nameNative}';
      }
      return constellation.iau;
    }
    
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = star.commonName ?? star.mainId ?? 'HIP ${star.hip}';
    final objectType = star.objectType ?? 'Star';
    final constellation = _getConstellationInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$objectType • $constellation',
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.75),
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
        if (star.imageUrl != null) ...[
          const SizedBox(height: 20),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                star.imageUrl!,
                height: 220,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: CupertinoActivityIndicator(
                        color: CupertinoColors.white,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
