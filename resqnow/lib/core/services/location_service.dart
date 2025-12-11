import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationService {
  /// Fetches position ONLY. Assumes permissions + GPS already checked.
  static Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  /// Real-time stream (clean)
  static Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    double distanceFilter = 1,
  }) {
    final settings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter.round(),
    );

    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// Reverse geocode
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
    } catch (_) {
      return null;
    }

    return null;
  }
}
