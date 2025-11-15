import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider extends ChangeNotifier {
  bool _useCurrentLocation = true;
  bool _hasUserChoice = false;

  double? _latitude;
  double? _longitude;

  bool _isFetching = false;
  String? _lastError;

  bool get useCurrentLocation => _useCurrentLocation;
  bool get hasUserChoice => _hasUserChoice;

  double? get latitude => _latitude;
  double? get longitude => _longitude;

  bool get isFetching => _isFetching;
  String? get lastError => _lastError;

  // 1. load stored settings
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _useCurrentLocation = prefs.getBool("useCurrentLocation") ?? true;
    _hasUserChoice = prefs.getBool("hasUserChoice") ?? false;

    _latitude = prefs.getDouble("latitude");
    _longitude = prefs.getDouble("longitude");

    notifyListeners();
  }

  // 2. save user choice to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("useCurrentLocation", _useCurrentLocation);
    await prefs.setBool("hasUserChoice", _hasUserChoice);

    if (_latitude != null) {
      await prefs.setDouble("latitude", _latitude!);
    }
    if (_longitude != null) {
      await prefs.setDouble("longitude", _longitude!);
    }
  }

  // 3. user selected YES/NO – save preferences
  void setUseCurrentLocation(bool value) {
    _useCurrentLocation = value;
    _hasUserChoice = true;

    _saveToPrefs();
    notifyListeners();
  }

  // 4. fetch GPS location + save to preferences
  Future<void> fetchCurrentLocation() async {
    if (!_useCurrentLocation) {
      _lastError = "Use current location = false";
      notifyListeners();
      return;
    }

    _isFetching = true;
    _lastError = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _lastError = "Location services are disabled";
        _isFetching = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _lastError = "Permission denied";
        _isFetching = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      print("📍 LAT: $_latitude");
      print("📍 LON: $_longitude");

      // 🔥 Uložit pozici
      await _saveToPrefs();

    } catch (e) {
      _lastError = "Failed to get location: $e";
      print("❌ $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }
}
