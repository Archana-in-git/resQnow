import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTestPage extends StatelessWidget {
  const MapTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(10.0, 76.0), // any coordinates
          zoom: 10,
        ),
      ),
    );
  }
}
