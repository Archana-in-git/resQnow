// core/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  /// Request location permission. Uses permission_handler first, then falls
  /// back to Geolocator.requestPermission to ensure the platform dialog is shown.
  static Future<bool> requestLocationPermission() async {
    // Quick check via permission_handler
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    // Try permission_handler request (shows dialog on many platforms)
    final result = await Permission.locationWhenInUse.request();
    if (result.isGranted) return true;

    // Fallback: use Geolocator's requestPermission to trigger platform dialog
    final geoStatus = await Geolocator.checkPermission();
    if (geoStatus == LocationPermission.denied) {
      final req = await Geolocator.requestPermission();
      if (req == LocationPermission.always ||
          req == LocationPermission.whileInUse) {
        return true;
      }
    } else if (geoStatus == LocationPermission.always ||
        geoStatus == LocationPermission.whileInUse) {
      return true;
    }

    // If permanently denied, open app settings so user can enable manually
    if (await Permission.locationWhenInUse.isPermanentlyDenied ||
        (await Geolocator.checkPermission()) ==
            LocationPermission.deniedForever) {
      await openAppSettings();
      return false;
    }

    return false;
  }
}
