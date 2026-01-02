import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/constellation.dart';
import 'star_catalog_service.dart';

class ConstellationCatalogService {
  static final ConstellationCatalogService _instance = ConstellationCatalogService._internal();
  factory ConstellationCatalogService() => _instance;
  ConstellationCatalogService._internal();

  List<Constellation> _constellations = [];
  bool _isLoaded = false;

  List<Constellation> get constellations => _constellations;
  bool get isLoaded => _isLoaded;

  /// Load constellations from the JSON file
  /// Only includes constellations where all stars have magnitude <= 8.5
  Future<void> loadConstellations() async {
    if (_isLoaded) return;

    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'lib/assets/data/constellation.json',
      );

      // Parse JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> constellationsData = jsonData['constellations'] as List<dynamic>;

      // Parse each constellation
      final List<Constellation> loadedConstellations = [];
      
      for (final constData in constellationsData) {
        final String? iau = constData['iau'] as String?;
        if (iau == null) continue;

        final Map<String, dynamic>? commonName = constData['common_name'] as Map<String, dynamic>?;
        final String? nameEnglish = commonName?['english'] as String?;
        final String? nameNative = commonName?['native'] as String?;

        final List<dynamic>? linesData = constData['lines'] as List<dynamic>?;
        if (linesData == null || linesData.isEmpty) continue;

        // Parse polylines and check if all stars are available
        final List<ConstellationPolyline> polylines = [];
        bool allStarsAvailable = true;

        for (final lineData in linesData) {
          try {
            final List<int> hipSequence = (lineData as List<dynamic>)
                .map((hip) {
                  if (hip is int) return hip;
                  if (hip is String) {
                    final parsed = int.tryParse(hip);
                    if (parsed == null) {
                      throw FormatException('Invalid HIP value: $hip');
                    }
                    return parsed;
                  }
                  throw FormatException('Invalid HIP type: ${hip.runtimeType}');
                })
                .toList();

            // Check if all stars in this polyline exist in catalog with mag <= 8.5
            for (final hip in hipSequence) {
              final star = StarCatalogService().getStarByHip(hip);
              if (star == null) {
                allStarsAvailable = false;
                break;
              }
            }

            if (!allStarsAvailable) break;

            polylines.add(ConstellationPolyline(hipSequence: hipSequence));
          } catch (e) {
            // Skip this line if there's a parsing error
            print('Warning: Skipping constellation line in $iau: $e');
            continue;
          }
        }

        // Only add constellation if all stars are available
        if (allStarsAvailable && polylines.isNotEmpty) {
          loadedConstellations.add(Constellation(
            iau: iau,
            lines: polylines,
            nameEnglish: nameEnglish,
            nameNative: nameNative,
          ));
        }
      }

      _constellations = loadedConstellations;
      _isLoaded = true;

      print('Loaded ${_constellations.length} constellations');
    } catch (e) {
      print('Error loading constellation catalog: $e');
      rethrow;
    }
  }

  /// Get a constellation by IAU code
  Constellation? getConstellationByIau(String iau) {
    try {
      return _constellations.firstWhere((c) => c.iau == iau);
    } catch (e) {
      return null;
    }
  }

  /// Find constellations that contain a specific star by HIP ID
  List<Constellation> getConstellationsForStar(int hip) {
    final List<Constellation> result = [];
    
    for (final constellation in _constellations) {
      for (final polyline in constellation.lines) {
        if (polyline.hipSequence.contains(hip)) {
          result.add(constellation);
          break; // No need to check more polylines in this constellation
        }
      }
    }
    
    return result;
  }

  /// Clear the catalog (useful for testing)
  void clear() {
    _constellations = [];
    _isLoaded = false;
  }
}
