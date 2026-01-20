import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/constellation.dart';
import '../models/constellation_type.dart';
import 'star_catalog_service.dart';

class ConstellationCatalogService {
  static final ConstellationCatalogService _instance = ConstellationCatalogService._internal();
  factory ConstellationCatalogService() => _instance;
  ConstellationCatalogService._internal();

  List<Constellation> _constellations = [];
  bool _isLoaded = false;
  ConstellationType _currentType = ConstellationType.western;

  List<Constellation> get constellations => _constellations;
  bool get isLoaded => _isLoaded;
  ConstellationType get currentType => _currentType;

  /// Load constellations from the JSON file for the specified type
  /// Only includes constellations where all stars have magnitude <= 8.5
  /// If type is not specified, uses the current type
  Future<void> loadConstellations([ConstellationType? type]) async {
    final constellationType = type ?? _currentType;
    
    if (_isLoaded && constellationType == _currentType) return;

    try {
      final String jsonString = await rootBundle.loadString(
        constellationType.assetPath,
      );

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> constellationsData = jsonData['constellations'] as List<dynamic>;

      final List<Constellation> loadedConstellations = [];
      
      for (final constData in constellationsData) {
        final String? iau = constData['iau'] as String?;
        final String? id = constData['id'] as String?;
        final String constellationKey = iau ?? id ?? '';
        
        if (constellationKey.isEmpty) continue;

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
            print('Warning: Skipping constellation line in $constellationKey: $e');
            continue;
          }
        }

        if (allStarsAvailable && polylines.isNotEmpty) {
          loadedConstellations.add(Constellation(
            iau: constellationKey,
            lines: polylines,
            nameEnglish: nameEnglish,
            nameNative: nameNative,
          ));
        }
      }

      _constellations = loadedConstellations;
      _currentType = constellationType;
      _isLoaded = true;

      print('Loaded ${_constellations.length} ${constellationType.displayName} constellations');
    } catch (e) {
      print('Error loading constellation catalog: $e');
      rethrow;
    }
  }

  Future<void> changeConstellationType(ConstellationType type) async {
    if (type == _currentType && _isLoaded) return;
    
    _isLoaded = false;
    await loadConstellations(type);
  }

  Constellation? getConstellationByIau(String iau) {
    try {
      return _constellations.firstWhere((c) => c.iau == iau);
    } catch (e) {
      return null;
    }
  }

  List<Constellation> getConstellationsForStar(int hip) {
    final List<Constellation> result = [];
    
    for (final constellation in _constellations) {
      for (final polyline in constellation.lines) {
        if (polyline.hipSequence.contains(hip)) {
          result.add(constellation);
          break;
        }
      }
    }
    
    return result;
  }

  void clear() {
    _constellations = [];
    _isLoaded = false;
  }
}
