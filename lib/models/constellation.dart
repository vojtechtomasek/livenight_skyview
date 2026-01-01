/// Full constellation definition for drawing.
class Constellation {
  final String iau;                 // e.g. "Ori" (stable key)
  final String? nameEnglish;        // e.g. "Orion"
  final String? nameNative;
  final List<ConstellationPolyline> lines;

  const Constellation({
    required this.iau,
    required this.lines,
    this.nameEnglish,
    this.nameNative,
  });
}

/// One polyline (chain) of constellation lines defined by Hipparcos star IDs.
/// Example: [98036, 97649, 97278] draws segments 98036->97649 and 97649->97278.
class ConstellationPolyline {
  final List<int> hipSequence;

  const ConstellationPolyline({
    required this.hipSequence,
  });
}
