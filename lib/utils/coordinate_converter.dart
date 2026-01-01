import 'dart:math' as math;

/// Converts equatorial coordinates (RA/Dec) to horizontal coordinates (Azimuth/Altitude)
/// based on observer's location and time
class CoordinateConverter {
  /// Convert Right Ascension and Declination to Azimuth and Altitude
  /// 
  /// Parameters:
  /// - raDeg: Right Ascension in degrees (0-360)
  /// - decDeg: Declination in degrees (-90 to +90)
  /// - latitude: Observer's latitude in degrees
  /// - longitude: Observer's longitude in degrees
  /// - dateTime: Current date and time (UTC)
  /// 
  /// Returns: [azimuth, altitude] in degrees
  static List<double> raDecToAzAlt({
    required double raDeg,
    required double decDeg,
    required double latitude,
    required double longitude,
    required DateTime dateTime,
  }) {
    // Convert to radians
    final ra = raDeg * math.pi / 180;
    final dec = decDeg * math.pi / 180;
    final lat = latitude * math.pi / 180;
    
    // Calculate Local Sidereal Time (LST)
    final lst = _calculateLST(longitude, dateTime);
    
    // Calculate Hour Angle
    final ha = lst - ra;
    
    // Convert to horizontal coordinates
    final sinAlt = math.sin(dec) * math.sin(lat) + 
                   math.cos(dec) * math.cos(lat) * math.cos(ha);
    final altitude = math.asin(sinAlt);
    
    final cosAz = (math.sin(dec) - math.sin(altitude) * math.sin(lat)) / 
                  (math.cos(altitude) * math.cos(lat));
    final sinAz = -math.sin(ha) * math.cos(dec) / math.cos(altitude);
    
    var azimuth = math.atan2(sinAz, cosAz);
    
    // Convert to degrees and normalize
    azimuth = azimuth * 180 / math.pi;
    if (azimuth < 0) azimuth += 360;
    
    final altitudeDeg = altitude * 180 / math.pi;
    
    return [azimuth, altitudeDeg];
  }
  
  /// Calculate Local Sidereal Time in radians
  static double _calculateLST(double longitude, DateTime dateTime) {
    // Convert to UTC if not already
    final utc = dateTime.toUtc();
    
    // Calculate Julian Date
    final jd = _calculateJulianDate(utc);
    
    // Calculate number of days since J2000.0
    final t = (jd - 2451545.0) / 36525.0;
    
    // Calculate Greenwich Mean Sidereal Time (GMST) in degrees
    var gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) +
               0.000387933 * t * t - t * t * t / 38710000.0;
    
    // Normalize to 0-360
    gmst = gmst % 360;
    if (gmst < 0) gmst += 360;
    
    // Calculate Local Sidereal Time
    var lst = gmst + longitude;
    lst = lst % 360;
    if (lst < 0) lst += 360;
    
    // Convert to radians
    return lst * math.pi / 180;
  }
  
  /// Calculate Julian Date from DateTime
  static double _calculateJulianDate(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month;
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final second = dateTime.second + dateTime.millisecond / 1000.0;
    
    var y = year;
    var m = month;
    
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    
    final jd = (365.25 * (y + 4716)).floor() +
               (30.6001 * (m + 1)).floor() +
               day + b - 1524.5 +
               (hour + minute / 60.0 + second / 3600.0) / 24.0;
    
    return jd;
  }
}
