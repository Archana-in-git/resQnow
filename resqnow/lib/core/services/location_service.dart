// core/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationService {
  /// Returns current position or null if unavailable.
  static Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Optionally open settings; caller should handle UI prompt.
        await Geolocator.openLocationSettings();
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied.
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  /// Stream for real-time/location updates.
  static Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 10,
  }) {
    final settings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// Reverse geocode to "City, Country"
  static Future<String?> getCityCountryFromPosition(Position position) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final city = p.locality ?? p.subAdministrativeArea ?? '';
        final country = p.country ?? '';
        final label = [city, country].where((s) => s.isNotEmpty).join(', ');
        return label.isNotEmpty ? label : null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
