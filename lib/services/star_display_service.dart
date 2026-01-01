import '../models/star_display.dart';
import '../utils/coordinate_converter.dart';
import 'star_catalog_service.dart';

class StarDisplayService {
  static final StarDisplayService _instance = StarDisplayService._internal();
  factory StarDisplayService() => _instance;
  StarDisplayService._internal();

  /// Convert catalog stars to display stars based on observer's location and time
  List<StarDisplay> getDisplayStars({
    required double latitude,
    required double longitude,
    required DateTime dateTime,
  }) {
    final stars = StarCatalogService().stars;
    final displayStars = <StarDisplay>[];
    
    for (final star in stars) {
      // Convert RA/Dec to Az/Alt
      final coords = CoordinateConverter.raDecToAzAlt(
        raDeg: star.raDeg,
        decDeg: star.decDeg,
        latitude: latitude,
        longitude: longitude,
        dateTime: dateTime,
      );
      
      final azimuth = coords[0];
      final altitude = coords[1];
      
      // Calculate size and opacity based on magnitude
      final size = calculateStarSize(star.mag);
      final opacity = calculateStarOpacity(star.mag);
      
      displayStars.add(StarDisplay(
        azimuth: azimuth,
        altitude: altitude,
        size: size,
        opacity: opacity,
        hip: star.hip,
        mag: star.mag,
      ));
    }
    
    return displayStars;
  }

  /// Calculate star size based on magnitude
  /// Magnitude range: -1.5 to 5.0
  /// Size range: 0.5 to 4.0
  /// Lower magnitude = brighter star = larger size
  double calculateStarSize(double mag) {
    if (mag < -1) return 4.0;
    if (mag > 5) return 0.5;
    
    // Linear interpolation: brighter stars (lower mag) = larger size
    return 4.0 - ((mag + 1.5) / 6.5) * 3.5;
  }
  
  /// Calculate star opacity based on magnitude
  /// Magnitude range: -1.5 to 5.0
  /// Opacity range: 0.3 to 1.0
  /// Lower magnitude = brighter star = higher opacity
  double calculateStarOpacity(double mag) {
    if (mag < 0) return 1.0;
    if (mag > 4.5) return 0.3;
    
    // Linear interpolation: brighter stars (lower mag) = higher opacity
    return 1.0 - (mag / 5.0) * 0.7;
  }
}
