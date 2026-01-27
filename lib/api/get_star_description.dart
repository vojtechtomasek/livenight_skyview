import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:livenight_skyview/models/star.dart';

class StarDescriptionService {
  static const _enBase = 'https://en.wikipedia.org/api/rest_v1';

  // Fetches a short description and image for a star
  // using Wikipedia REST API.
  Future<Star> fetchDescription({
    required Star baseStar,
  }) async {
    final title = _resolveTitle(baseStar);
    if (title == null) return baseStar;

    final en = await _fetchSummary(_enBase, title);
    if (en != null) {
      return _apply(baseStar, en);
    }

    return baseStar;
  }

  String? _resolveTitle(Star star) {
    if (star.commonName != null && star.commonName!.isNotEmpty) {
      return star.commonName!;
    }

    if (star.mainId != null && star.mainId!.isNotEmpty) {
      final cleaned =
          star.mainId!.startsWith('* ') ? star.mainId!.substring(2) : star.mainId!;
      return cleaned;
    }

    return null;
  }

  Future<_WikiData?> _fetchSummary(String base, String title) async {
    final url = '$base/page/summary/${Uri.encodeComponent(title)}';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) return null;

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;

    final extract = jsonBody['extract'] as String?;
    if (extract == null || extract.trim().isEmpty) return null;

    final imageUrl =
        (jsonBody['originalimage'] as Map<String, dynamic>?)?['source'] as String? ??
        (jsonBody['thumbnail'] as Map<String, dynamic>?)?['source'] as String?;

    return _WikiData(
      description: extract.trim(),
      imageUrl: imageUrl,
    );
  }

  Star _apply(Star baseStar, _WikiData data) {
    return Star(
      hip: baseStar.hip,
      raDeg: baseStar.raDeg,
      decDeg: baseStar.decDeg,
      mag: baseStar.mag,
      constellations: baseStar.constellations,

      mainId: baseStar.mainId,
      commonName: baseStar.commonName,
      vMag: baseStar.vMag,
      parallaxMas: baseStar.parallaxMas,
      spectralType: baseStar.spectralType,
      objectType: baseStar.objectType,
      raDegDetail: baseStar.raDegDetail,
      decDegDetail: baseStar.decDegDetail,
      detailFetchedAt: baseStar.detailFetchedAt,

      description: data.description,
      imageUrl: data.imageUrl,
    );
  }
}

class _WikiData {
  final String description;
  final String? imageUrl;

  const _WikiData({
    required this.description,
    this.imageUrl,
  });
}
