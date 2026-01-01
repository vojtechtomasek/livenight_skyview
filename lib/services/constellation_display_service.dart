import '../models/constellation.dart';
import '../utils/coordinate_converter.dart';
import 'star_catalog_service.dart';
import 'constellation_catalog_service.dart';

class ConstellationLine {
  final List<ConstellationPoint> points;

  ConstellationLine(this.points);
}

class ConstellationPoint {
  final double azimuth;
  final double altitude;

  ConstellationPoint(this.azimuth, this.altitude);
}

class ConstellationDisplayService {
  static final ConstellationDisplayService _instance = ConstellationDisplayService._internal();
  factory ConstellationDisplayService() => _instance;
  ConstellationDisplayService._internal();

  /// Get constellation lines converted to display coordinates
  List<ConstellationLine> getConstellationLines({
    required double latitude,
    required double longitude,
    required DateTime dateTime,
  }) {
    final constellations = ConstellationCatalogService().constellations;
    final displayLines = <ConstellationLine>[];

    for (final constellation in constellations) {
      for (final polyline in constellation.lines) {
        final points = <ConstellationPoint>[];
        
        for (final hip in polyline.hipSequence) {
          final star = StarCatalogService().getStarByHip(hip);
          if (star == null) continue;

          // Convert RA/Dec to Az/Alt
          final coords = CoordinateConverter.raDecToAzAlt(
            raDeg: star.raDeg,
            decDeg: star.decDeg,
            latitude: latitude,
            longitude: longitude,
            dateTime: dateTime,
          );

          points.add(ConstellationPoint(coords[0], coords[1]));
        }

        // Only add line if we have at least 2 points
        if (points.length >= 2) {
          displayLines.add(ConstellationLine(points));
        }
      }
    }

    return displayLines;
  }
}
