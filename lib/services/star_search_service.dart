import '../models/star.dart';
import 'star_catalog_service.dart';

class StarSearchService {
  static final StarSearchService _instance = StarSearchService._internal();
  factory StarSearchService() => _instance;
  StarSearchService._internal();

  /// Search stars with smart detection of search type
  List<Star> searchStars(String query) {
    if (query.isEmpty) return [];
    
    final stars = StarCatalogService().stars;
    final searchQuery = query.trim();
    final searchLower = searchQuery.toLowerCase();
    final results = <Star>[];
    
    // 1. Check if it's a pure number - search by HIP
    final pureNumber = int.tryParse(searchQuery);
    if (pureNumber != null) {
      final star = StarCatalogService().getStarByHip(pureNumber);
      if (star != null) {
        return [star];
      }
      // If exact match not found, search for partial HIP matches
      for (final star in stars) {
        if (star.hip.toString().contains(searchQuery)) {
          results.add(star);
        }
      }
      return _sortAndLimit(results);
    }
    
    // 2. Check if it starts with "HIP" or "HIP " - explicit HIP search
    if (searchLower.startsWith('hip')) {
      final hipPart = searchLower.replaceAll('hip', '').trim();
      final hipNum = int.tryParse(hipPart);
      
      if (hipNum != null) {
        final star = StarCatalogService().getStarByHip(hipNum);
        if (star != null) {
          return [star];
        }
      }
      
      // Partial HIP number search
      for (final star in stars) {
        if (star.hip.toString().contains(hipPart)) {
          results.add(star);
        }
      }
      return _sortAndLimit(results);
    }
    
    // 3. Check if it looks like a SIMBAD ID pattern (e.g., "* alf Ori", "V* ", "NAME ")
    if (_looksLikeSimbadId(searchLower)) {
      for (final star in stars) {
        if (star.mainId != null && 
            star.mainId!.toLowerCase().contains(searchLower)) {
          results.add(star);
        }
      }
      // If SIMBAD search found results, return them
      if (results.isNotEmpty) {
        return _sortAndLimit(results);
      }
    }
    
    // 4. Default: Search by common name (most user-friendly)
    for (final star in stars) {
      // Exact common name match (highest priority)
      if (star.commonName != null && 
          star.commonName!.toLowerCase() == searchLower) {
        return [star];
      }
      
      // Partial common name match
      if (star.commonName != null && 
          star.commonName!.toLowerCase().contains(searchLower)) {
        results.add(star);
      }
    }
    
    // 5. If no common name matches, fallback to SIMBAD ID search
    if (results.isEmpty) {
      for (final star in stars) {
        if (star.mainId != null && 
            star.mainId!.toLowerCase().contains(searchLower)) {
          results.add(star);
        }
      }
    }
    
    return _sortAndLimit(results);
  }
  
  /// Check if query looks like a SIMBAD identifier
  bool _looksLikeSimbadId(String query) {
    // Common SIMBAD prefixes
    const simbadPrefixes = [
      '* ',           // Star
      'v* ',          // Variable star
      'name ',        // Named object
      'hd ',          // Henry Draper
      'hr ',          // Harvard Revised
      'bd ',          // Bonner Durchmusterung
      'cd ',          // Cordoba Durchmusterung
      'sao ',         // SAO catalog
      'gj ',          // Gliese-Jahreiss
      'gl ',          // Gliese
    ];
    
    for (final prefix in simbadPrefixes) {
      if (query.startsWith(prefix)) {
        return true;
      }
    }
    
    // Check for Greek letter patterns (alf, bet, gam, etc.)
    if (query.contains('alf ') || query.contains('bet ') || 
        query.contains('gam ') || query.contains('del ')) {
      return true;
    }
    
    return false;
  }
  
  /// Sort results by magnitude (brightest first) and limit to 20
  List<Star> _sortAndLimit(List<Star> results) {
    results.sort((a, b) => a.mag.compareTo(b.mag));
    return results.take(20).toList();
  }
  
  /// Get search type description for UI display
  String getSearchTypeHint(String query) {
    if (query.trim().isEmpty) return 'Search by name or number';
    
    final searchLower = query.toLowerCase().trim();
    
    if (int.tryParse(query.trim()) != null) {
      return 'Searching HIP number...';
    }
    
    if (searchLower.startsWith('hip')) {
      return 'Searching HIP catalog...';
    }
    
    if (_looksLikeSimbadId(searchLower)) {
      return 'Searching SIMBAD ID...';
    }
    
    return 'Searching star names...';
  }
}
