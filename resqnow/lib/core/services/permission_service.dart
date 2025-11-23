import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  static Future<bool> requestLocationPermission() async {
    // 1. Check Geolocator permission status
    LocationPermission status = await Geolocator.checkPermission();

    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      return true;
    }

    // 2. Request permission using Geolocator only
    status = await Geolocator.requestPermission();

    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      return true;
    }

    // 3. Permission permanently denied
    if (status == LocationPermission.deniedForever) {
      await openAppSettings();
      return false;
    }

    return false;
  }
}
