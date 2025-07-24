import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapConstants {
  static const double defaultZoom = 14.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 18.0;

  static const CameraPosition defaultCameraPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629), // India center fallback
    zoom: defaultZoom,
  );

  static const double mapPaddingBottom = 180.0;
  static const double markerIconSize = 100.0;
}
