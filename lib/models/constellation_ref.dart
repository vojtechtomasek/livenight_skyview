/// Reference to a constellation for UI display purposes.
class ConstellationRef {
  final String iau;           // e.g. "Ori"
  final String? nameEnglish;  // e.g. "Orion"
  final String? nameNative;   // optional localized/native name

  const ConstellationRef({
    required this.iau,
    this.nameEnglish,
    this.nameNative,
  });
}