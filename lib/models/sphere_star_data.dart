class SphereStarData {
  final double azimuth; // Azimut ve stupních (0–360)
  final double elevation; // Elevace ve stupních (-90 až +90)
  final double size; // Velikost hvězdy
  final bool isBright; // Zda je hvězda jasná
  final String name; // Jméno hvězdy

  SphereStarData(this.azimuth, this.elevation, this.size, this.isBright, this.name);

  static List<SphereStarData> getAllStars() {
    return [
      // Jasné hvězdy v různých směrech (severní polokoule)
      SphereStarData(0, 50, 3.0, true, 'Polaris'),
      SphereStarData(90, 25, 2.5, true, 'Star East'),
      SphereStarData(180, 30, 2.8, true, 'Star South'),
      SphereStarData(270, 20, 2.2, true, 'Star West'),

      // Jasné hvězdy na jižní polokouli
      SphereStarData(45, -30, 2.4, true, 'Star SE'),
      SphereStarData(135, -25, 2.6, true, 'Star SW1'),
      SphereStarData(225, -35, 2.3, true, 'Star NW'),
      SphereStarData(315, -20, 2.5, true, 'Star NE'),

      // Velký vůz (severní část oblohy)
      SphereStarData(195, 55, 2.0, false, 'Dubhe'),
      SphereStarData(205, 58, 1.8, false, 'Merak'),
      SphereStarData(215, 60, 1.9, false, 'Phecda'),
      SphereStarData(225, 62, 1.7, false, 'Megrez'),
      SphereStarData(235, 60, 1.8, false, 'Alioth'),
      SphereStarData(245, 57, 1.6, false, 'Mizar'),
      SphereStarData(255, 54, 1.7, false, 'Alkaid'),

      // Orion (zimní souhvězdí)
      SphereStarData(80, 5, 2.1, false, 'Betelgeuse'),
      SphereStarData(85, 0, 1.9, false, 'Bellatrix'),
      SphereStarData(90, -2, 2.0, false, 'Rigel'),
      SphereStarData(95, 2, 1.8, false, 'Alnilam'),
      SphereStarData(100, 8, 1.7, false, 'Mintaka'),

      // Kassiopea (W tvar)
      SphereStarData(10, 65, 1.8, false, 'Caph'),
      SphereStarData(20, 68, 1.6, false, 'Schedar'),
      SphereStarData(30, 65, 1.7, false, 'Navi'),
      SphereStarData(40, 68, 1.5, false, 'Ruchbah'),
      SphereStarData(50, 65, 1.6, false, 'Segin'),

      // Hvězdy severní polokoule (vysoká elevace)
      SphereStarData(60, 70, 1.4, false, 'Star N1'),
      SphereStarData(120, 75, 1.3, false, 'Star N2'),
      SphereStarData(180, 72, 1.5, false, 'Star N3'),
      SphereStarData(240, 68, 1.2, false, 'Star N4'),
      SphereStarData(300, 71, 1.4, false, 'Star N5'),

      // Střední pás oblohy (kolem rovníku)
      SphereStarData(30, 35, 1.5, false, 'Star M1'),
      SphereStarData(60, 25, 1.3, false, 'Star M2'),
      SphereStarData(120, 40, 1.4, false, 'Star M3'),
      SphereStarData(150, 30, 1.2, false, 'Star M4'),
      SphereStarData(210, 35, 1.6, false, 'Star M5'),
      SphereStarData(270, 32, 1.3, false, 'Star M6'),
      SphereStarData(330, 28, 1.4, false, 'Star M7'),

      // Hvězdy jižní polokoule (negativní elevace)
      SphereStarData(0, -40, 1.4, false, 'Star S1'),
      SphereStarData(60, -50, 1.3, false, 'Star S2'),
      SphereStarData(120, -45, 1.5, false, 'Star S3'),
      SphereStarData(180, -60, 1.2, false, 'Star S4'),
      SphereStarData(240, -35, 1.4, false, 'Star S5'),
      SphereStarData(300, -55, 1.3, false, 'Star S6'),

      // Další hvězdy na jižní polokouli
      SphereStarData(15, -25, 1.2, false, 'Star S7'),
      SphereStarData(75, -30, 1.1, false, 'Star S8'),
      SphereStarData(135, -20, 1.3, false, 'Star S9'),
      SphereStarData(195, -45, 1.0, false, 'Star S10'),
      SphereStarData(255, -40, 1.2, false, 'Star S11'),
      SphereStarData(315, -35, 1.1, false, 'Star S12'),

      // Nízké elevace (blízko horizontu)
      SphereStarData(45, 10, 1.3, false, 'Star H1'),
      SphereStarData(135, 15, 1.5, false, 'Star H2'),
      SphereStarData(225, 8, 1.3, false, 'Star H3'),
      SphereStarData(315, 12, 1.4, false, 'Star H4'),

      // Nízké elevace na druhé straně (záporné)
      SphereStarData(45, -10, 1.2, false, 'Star L1'),
      SphereStarData(135, -15, 1.4, false, 'Star L2'),
      SphereStarData(225, -8, 1.2, false, 'Star L3'),
      SphereStarData(315, -12, 1.3, false, 'Star L4'),

      // Slabé hvězdy rozmístěné po celé sféře
      SphereStarData(15, 20, 1.0, false, 'Star D1'),
      SphereStarData(75, 35, 1.1, false, 'Star D2'),
      SphereStarData(165, 45, 1.0, false, 'Star D3'),
      SphereStarData(255, 30, 1.2, false, 'Star D4'),
      SphereStarData(345, 40, 1.0, false, 'Star D5'),

      // Slabé hvězdy na jižní polokouli
      SphereStarData(15, -20, 0.9, false, 'Star D6'),
      SphereStarData(75, -35, 1.0, false, 'Star D7'),
      SphereStarData(165, -45, 0.9, false, 'Star D8'),
      SphereStarData(255, -30, 1.1, false, 'Star D9'),
      SphereStarData(345, -40, 0.9, false, 'Star D10'),

      // Dodatečné hvězdy pro hustší oblohu na obou polokoulích
      SphereStarData(52, 42, 1.1, false, 'Star A1'),
      SphereStarData(108, 18, 1.0, false, 'Star A2'),
      SphereStarData(172, 52, 1.2, false, 'Star A3'),
      SphereStarData(238, 38, 1.0, false, 'Star A4'),
      SphereStarData(295, 55, 1.1, false, 'Star A5'),
      SphereStarData(358, 48, 1.0, false, 'Star A6'),

      // Zrcadlové hvězdy na jižní polokouli
      SphereStarData(52, -42, 1.0, false, 'Star A7'),
      SphereStarData(108, -18, 0.9, false, 'Star A8'),
      SphereStarData(172, -52, 1.1, false, 'Star A9'),
      SphereStarData(238, -38, 0.9, false, 'Star A10'),
      SphereStarData(295, -55, 1.0, false, 'Star A11'),
      SphereStarData(358, -48, 0.9, false, 'Star A12'),

      // Hvězdy velmi blízko "spodního pólu" (elevace -80°)
      SphereStarData(0, -80, 1.1, false, 'Star P1'),
      SphereStarData(90, -85, 1.0, false, 'Star P2'),
      SphereStarData(180, -80, 1.2, false, 'Star P3'),
      SphereStarData(270, -85, 1.0, false, 'Star P4'),
    ];
  }
}
