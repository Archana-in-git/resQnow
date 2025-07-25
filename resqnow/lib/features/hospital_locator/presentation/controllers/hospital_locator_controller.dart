import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resqnow/core/services/location_service.dart';
import '../../data/services/hospital_service.dart';
import '../../../data/models/hospital_model.dart';

class HospitalLocatorController extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final HospitalService _hospitalService = HospitalService();

  LatLng? _currentLocation;
  List<HospitalModel> _hospitals = [];
  HospitalModel? _selectedHospital;
  bool _isLoading = false;
  String? _error;
  Set<Marker> _markers = {};

  LatLng? get currentLocation => _currentLocation;
  List<HospitalModel> get hospitals => _hospitals;
  HospitalModel? get selectedHospital => _selectedHospital;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<Marker> get markers => _markers;

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      _currentLocation = LatLng(position.latitude, position.longitude);

      _hospitals = await _hospitalService.getNearbyHospitals(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );

      _generateMarkers();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectHospital(HospitalModel hospital) {
    _selectedHospital = hospital;
    notifyListeners();
  }

  void _generateMarkers() {
    _markers.clear();

    for (var hospital in _hospitals) {
      _markers.add(
        Marker(
          markerId: MarkerId(hospital.placeId ?? hospital.name),
          position: LatLng(hospital.latitude, hospital.longitude),
          infoWindow: InfoWindow(title: hospital.name),
          onTap: () => selectHospital(hospital),
        ),
      );
    }
  }
}
