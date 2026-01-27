/// Service to map common star names to HIP numbers
class StarNamesService {
  static final StarNamesService _instance = StarNamesService._internal();
  factory StarNamesService() => _instance;
  StarNamesService._internal();

  /// Map of common star names to HIP numbers
  /// This includes the brightest and most well-known stars
  static const Map<String, int> _commonNames = {
    // Brightest stars
    'sirius': 32349,
    'canopus': 30438,
    'arcturus': 69673,
    'vega': 91262,
    'capella': 24608,
    'rigel': 24436,
    'procyon': 37279,
    'betelgeuse': 27989,
    'achernar': 7588,
    'altair': 97649,
    'aldebaran': 21421,
    'antares': 80763,
    'spica': 65474,
    'pollux': 37826,
    'fomalhaut': 113368,
    'deneb': 102098,
    'regulus': 49669,
    'adhara': 33579,
    'castor': 36850,
    'shaula': 85927,
    'bellatrix': 25336,
    'alnilam': 26311,
    'alnair': 109268,
    'alioth': 62956,
    'mirfak': 15863,
    'dubhe': 54061,
    'alkaid': 67301,
    'mizar': 65378,
    'polaris': 11767,
    'acrux': 60718,
    'mimosa': 62434,
    'hadar': 68702,
    'rigil kentaurus': 71683,
    'alpha centauri': 71683,
    'proxima centauri': 70890,
    'barnard\'s star': 87937,
    'wolf 359': 54035,
    'lalande 21185': 54211,
    'sirius b': 32349,
    'luyten 726-8': 104214,
    'ross 154': 92403,
    'ross 248': 3829,
    'epsilon eridani': 16537,
    'lacaille 9352': 105090,
    'ross 128': 57548,
    'eridani': 16537,
    '61 cygni': 104214,
    'tau ceti': 8102,
    'gliese 876': 113020,
    
    // Greek letter designations (common ones)
    'alpha orionis': 27989,  // Betelgeuse
    'beta orionis': 24436,   // Rigel
    'gamma orionis': 25336,  // Bellatrix
    'delta orionis': 25930,  // Mintaka
    'epsilon orionis': 26311, // Alnilam
    'zeta orionis': 26727,   // Alnitak
    
    'alpha canis majoris': 32349, // Sirius
    'alpha carinae': 30438,       // Canopus
    'alpha bootis': 69673,        // Arcturus
    'alpha lyrae': 91262,         // Vega
    'alpha aurigae': 24608,       // Capella
    'alpha canis minoris': 37279, // Procyon
    'alpha eridani': 7588,        // Achernar
    'alpha aquilae': 97649,       // Altair
    'alpha tauri': 21421,         // Aldebaran
    'alpha scorpii': 80763,       // Antares
    'alpha virginis': 65474,      // Spica
    'beta geminorum': 37826,      // Pollux
    'alpha piscis austrini': 113368, // Fomalhaut
    'alpha cygni': 102098,        // Deneb
    'alpha leonis': 49669,        // Regulus
    'alpha crucis': 60718,        // Acrux
    'beta crucis': 62434,         // Mimosa
    'alpha centauri a': 71683,
    'alpha centauri b': 71681,
    
    // Ursa Major (Big Dipper)
    'merak': 53910,
    'phecda': 58001,
    'megrez': 59774,
    
    // Cassiopeia
    'schedar': 3179,
    'caph': 746,
    'ruchbah': 6686,
    'segin': 8886,
    
    // Orion belt
    'alnitak': 26727,
    'mintaka': 25930,
    
    // Other well-known stars
    'algol': 14576,
    'mira': 10826,
    'rasalgethi': 84345,
    'izar': 72105,
    'kochab': 72607,
    'alphard': 46390,
    'suhail': 44816,
    'avior': 41037,
    'menkalinan': 25428,
    'atria': 82273,
    'alhena': 31681,
    'peacock': 100751,
    'alsephina': 60965,
    'mirzam': 30324,
    'alpheratz': 677,
    'kaus australis': 90185,
    'menkar': 14135,
    'nunki': 92855,
    'scheat': 113881,
    'alderamin': 105199,
    'ankaa': 2081,
    'enif': 107315,
    'markab': 113963,
    'sabik': 84012,
    'rasalhague': 86032,
    'etamin': 87833,
    'algieba': 50583,
    'zubenelgenubi': 74785,
    'alphecca': 76267,
    'diphda': 3419,
    'naos': 39429,
    'sadalsuud': 109074,
    'menkent': 68933,
    'eltanin': 87833,
  };

  /// Search for a star by common name
  /// Returns null if no star is found with that name
  int? getHipByName(String name) {
    final normalizedName = name.trim().toLowerCase();
    return _commonNames[normalizedName];
  }

  /// Get all names that contain the search query
  Map<String, int> searchNames(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    final results = <String, int>{};
    
    for (final entry in _commonNames.entries) {
      if (entry.key.contains(normalizedQuery)) {
        results[entry.key] = entry.value;
      }
    }
    
    return results;
  }
  
  /// Get common name by HIP number
  /// Returns the first matching common name (capitalized) or null if not found
  String? getNameByHip(int hip) {
    for (final entry in _commonNames.entries) {
      if (entry.value == hip) {
        // Capitalize first letter of each word
        return entry.key.split(' ')
            .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
            .join(' ');
      }
    }
    return null;
  }
}
