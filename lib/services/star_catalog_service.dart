import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:livenight_skyview/models/star.dart';

class StarCatalogService {
  static final StarCatalogService _instance = StarCatalogService._internal();
  factory StarCatalogService() => _instance;
  StarCatalogService._internal();

  List<Star> _stars = [];
  bool _isLoaded = false;

  List<Star> get stars => _stars;
  bool get isLoaded => _isLoaded;

  /// Load stars from the JSON file with magnitude less than the specified threshold
  Future<void> loadStars({double maxMagnitude = 5.0}) async {
    if (_isLoaded) return;

    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'lib/assets/data/star_dataset.json',
      );

      // Parse JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> data = jsonData['data'] as List<dynamic>;

      // Parse each star entry
      final List<Star> loadedStars = [];
      for (final entry in data) {
        final List<dynamic> starData = entry as List<dynamic>;
        
        // Extract fields based on metadata order: hip, ra_deg, dec_deg, mag
        final int? hip = starData[0] as int?;
        final num? raNum = starData[1] as num?;
        final num? decNum = starData[2] as num?;
        final num? magNum = starData[3] as num?;

        // Skip stars with missing critical data
        if (hip == null || raNum == null || decNum == null || magNum == null) {
          continue;
        }

        final double raDeg = raNum.toDouble();
        final double decDeg = decNum.toDouble();
        final double mag = magNum.toDouble();

        // Filter by magnitude
        if (mag < maxMagnitude) {
          loadedStars.add(Star(
            hip: hip,
            raDeg: raDeg,
            decDeg: decDeg,
            mag: mag,
          ));
        }
      }

      _stars = loadedStars;
      _isLoaded = true;

      print('Loaded ${_stars.length} stars with magnitude < $maxMagnitude');
    } catch (e) {
      print('Error loading star catalog: $e');
      rethrow;
    }
  }

  /// Get a star by HIP ID
  Star? getStarByHip(int hip) {
    try {
      return _stars.firstWhere((star) => star.hip == hip);
    } catch (e) {
      return null;
    }
  }

  /// Clear the catalog (useful for testing)
  void clear() {
    _stars = [];
    _isLoaded = false;
  }
}
