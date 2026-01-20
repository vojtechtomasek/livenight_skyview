/// Enum representing different cultural constellation patterns
enum ConstellationType {
  western('Western', 'western_constellation.json'),
  chinese('Chinese', 'chinese_constellation.json'),
  egyptian('Egyptian', 'egyptian_constellation.json'),
  indian('Indian', 'indian_constellation.json'),
  norse('Norse', 'norse_constellation.json'),
  romanian('Romanian', 'romanian_constellation.json');

  const ConstellationType(this.displayName, this.fileName);
  
  final String displayName;
  
  final String fileName;
  
  String get assetPath => 'lib/assets/data/$fileName';
}
