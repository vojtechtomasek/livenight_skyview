import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:livenight_skyview/models/star.dart';

class StarDetailService {
  static const _endpoint =
      'https://simbad.u-strasbg.fr/simbad/sim-tap/sync';

  /// Fetches detailed information for a star identified by HIP number
  /// and returns a new Star instance enriched with online data.
  Future<Star> fetchStarDetail({
    required Star baseStar,
  }) async {
    final query =
        "SELECT TOP 1 b.main_id,n.id AS name_id,f.V AS vmag,"
        "b.plx_value,b.sp_type,b.otype,b.ra,b.dec "
        "FROM basic b "
        "JOIN ident i ON i.oidref=b.oid AND i.id='HIP ${baseStar.hip}' "
        "LEFT JOIN ident n ON n.oidref=b.oid AND n.id LIKE 'NAME %' "
        "LEFT JOIN allfluxes f ON f.oidref=b.oid";

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'REQUEST': 'doQuery',
        'LANG': 'ADQL',
        'FORMAT': 'json',
        'QUERY': query,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load star detail (HTTP ${response.statusCode})',
      );
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as List<dynamic>;

    if (data.isEmpty) {
      // No detail found → return original star unchanged
      return baseStar;
    }

    final row = data.first as List<dynamic>;

    final String? mainId = row[0] as String?;
    final String? nameId = row[1] as String?;
    final double? vMag = row[2] as double?;
    final double? parallaxMas = row[3] as double?;
    final String? spectralType = row[4] as String?;
    final String? objectType = row[5] as String?;
    final double? raDegDetail = row[6] as double?;
    final double? decDegDetail = row[7] as double?;

    final String? commonName = nameId != null && nameId.startsWith('NAME ')
        ? nameId.substring(5)
        : null;

    return Star(
      hip: baseStar.hip,
      raDeg: baseStar.raDeg,
      decDeg: baseStar.decDeg,
      mag: baseStar.mag,
      constellations: baseStar.constellations,

      mainId: mainId,
      commonName: commonName,
      vMag: vMag,
      parallaxMas: parallaxMas,
      spectralType: spectralType,
      objectType: objectType,
      raDegDetail: raDegDetail,
      decDegDetail: decDegDetail,
      detailFetchedAt: DateTime.now(),
    );
  }
}
