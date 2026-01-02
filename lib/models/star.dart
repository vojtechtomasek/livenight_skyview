import 'package:livenight_skyview/models/constellation_ref.dart';

class Star {
  // core (offline catalog)
  final int hip;
  final double raDeg;   // Right Ascension in degrees
  final double decDeg;  // Declination in degrees
  final double mag;     // Visual magnitude (V) for rendering

  // constellation membership (offline derived)
  final List<ConstellationRef> constellations; // usually 0 or 1, sometimes more; i will maybe delete this later (not sure if its optimal)

  // optional (online detail)
  final String? mainId;         // e.g. "* alf Ori"
  final String? commonName;     // e.g. "Betelgeuse"
  final double? vMag;           // V magnitude from detail source (optional)
  final double? parallaxMas;    // Parallax in mas (optional)
  final String? spectralType;   // e.g. "M1-M2Ia-Iab" (optional)
  final String? objectType;     // SIMBAD object type code (optional)
  final double? raDegDetail;    // RA from detail source, if provided
  final double? decDegDetail;   // Dec from detail source, if provided

  final String? description;
  final String? imageUrl;

  final DateTime? detailFetchedAt;

  const Star({
    required this.hip,
    required this.raDeg,
    required this.decDeg,
    required this.mag,
    this.constellations = const [],
    this.mainId,
    this.commonName,
    this.vMag,
    this.parallaxMas,
    this.spectralType,
    this.objectType,
    this.raDegDetail,
    this.decDegDetail,
    this.description,
    this.imageUrl,
    this.detailFetchedAt,
  });
}