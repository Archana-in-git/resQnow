import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalPage extends StatefulWidget {
  const HospitalPage({Key? key}) : super(key: key);

  @override
  State<HospitalPage> createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {

  /// 🔐 REPLACE WITH YOUR REAL DEPLOYED FUNCTION URL
  static const String backendUrl =
      "https://us-central1-yourproject.cloudfunctions.net/nearbyHospitals";

  final Completer<GoogleMapController> _mapController = Completer();
  final PanelController _panelController = PanelController();
  final TextEditingController _searchCtrl = TextEditingController();

  LatLng? _userLatLng;
  final Set<Marker> _markers = {};
  String? _selectedPlaceId;

  bool _loading = true;
  String? _error;

  final List<_Hospital> _hospitals = [];
  String _query = "";

  static const double _initZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _initFlow();

    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// ================= INIT FLOW =================
  Future<void> _initFlow() async {
    try {
      final pos = await _getUserLocation();
      _userLatLng = LatLng(pos.latitude, pos.longitude);

      _markers.add(
        Marker(
          markerId: const MarkerId("me"),
          position: _userLatLng!,
          infoWindow: const InfoWindow(title: "You are here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );

      await _fetchNearbyHospitals();

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
      });

      final c = await _mapController.future;
      await c.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _userLatLng!, zoom: _initZoom),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// ================= LOCATION =================
  Future<Position> _getUserLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw "Enable Location Services";

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw "Location permission denied";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw "Location permission permanently denied";
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// ================= FETCH FROM FIREBASE BACKEND =================
  Future<void> _fetchNearbyHospitals() async {
    if (_userLatLng == null) return;

    final url =
        "$backendUrl?lat=${_userLatLng!.latitude}&lng=${_userLatLng!.longitude}";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw "Backend error (${res.statusCode})";
    }

    final data = jsonDecode(res.body);
    final status = data["status"] ?? "UNKNOWN";

    if (status != "OK" && status != "ZERO_RESULTS") {
      throw "Places API status: $status";
    }

    final results =
        List<Map<String, dynamic>>.from(data["results"] ?? []);

    _hospitals.clear();
    _markers.removeWhere((m) => m.markerId.value != "me");

    for (final place in results) {
      final lat =
          (place["geometry"]["location"]["lat"] as num).toDouble();
      final lng =
          (place["geometry"]["location"]["lng"] as num).toDouble();

      final name = (place["name"] ?? "") as String;
      final rating = (place["rating"] is num)
          ? (place["rating"] as num).toDouble()
          : null;

      final address =
          (place["vicinity"] ?? "") as String? ?? "";

      final placeId = (place["place_id"] ?? "") as String;

      final distMeters = Geolocator.distanceBetween(
        _userLatLng!.latitude,
        _userLatLng!.longitude,
        lat,
        lng,
      );

      final hospital = _Hospital(
        placeId: placeId,
        name: name,
        latLng: LatLng(lat, lng),
        rating: rating,
        address: address,
        distanceMeters: distMeters,
      );

      _hospitals.add(hospital);
      _markers.add(_markerFor(hospital, selected: false));
    }

    _hospitals.sort(
      (a, b) => a.distanceMeters.compareTo(b.distanceMeters),
    );

    if (!mounted) return;
    setState(() {});
  }

  /// ================= MAP HELPERS =================
  Marker _markerFor(_Hospital h, {required bool selected}) {
    return Marker(
      markerId: MarkerId(h.placeId),
      position: h.latLng,
      infoWindow: InfoWindow(title: h.name, snippet: h.address),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        selected
            ? BitmapDescriptor.hueGreen
            : BitmapDescriptor.hueRed,
      ),
      onTap: () {
        setState(() => _selectedPlaceId = h.placeId);
        _openPanelIfNeeded();
      },
    );
  }

  void _openPanelIfNeeded() {
    if (_panelController.isPanelClosed) {
      _panelController.open();
    }
  }

  Future<void> _moveTo(LatLng target,
      {double zoom = 17}) async {
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  Future<void> _openInGoogleMaps(_Hospital h) async {
    final uri = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=${h.latLng.latitude},${h.latLng.longitude}&destination_place_id=${h.placeId}");

    await launchUrl(uri,
        mode: LaunchMode.externalApplication);
  }

  List<_Hospital> get _filtered {
    if (_query.isEmpty) return _hospitals;
    return _hospitals
        .where((h) =>
            h.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Hospitals"),
        backgroundColor: Colors.teal,
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Colors.teal))
          : _error != null
              ? _buildError()
              : _buildMap(),
      floatingActionButton: _userLatLng == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: () =>
                  _moveTo(_userLatLng!, zoom: 16),
              child: const Icon(Icons.my_location),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_error!,
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _initFlow();
            },
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _userLatLng ??
                const LatLng(20.5937, 78.9629),
            zoom: _initZoom,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers,
          onMapCreated: (c) =>
              _mapController.complete(c),
        ),

        SlidingUpPanel(
          controller: _panelController,
          minHeight: 110,
          maxHeight:
              MediaQuery.of(context).size.height * 0.62,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22)),
          panelBuilder: (sc) => _buildPanel(sc),
        ),
      ],
    );
  }

  Widget _buildPanel(ScrollController sc) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),

        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: "Search hospitals...",
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            controller: sc,
            itemCount: _filtered.length,
            itemBuilder: (context, i) {
              final h = _filtered[i];
              final km = h.distanceMeters / 1000;

              return ListTile(
                title: Text(h.name),
                subtitle: Text(
                    "${km.toStringAsFixed(1)} km away"),
                trailing: IconButton(
                  icon: const Icon(Icons.navigation,
                      color: Colors.teal),
                  onPressed: () =>
                      _openInGoogleMaps(h),
                ),
                onTap: () async {
                  await _moveTo(h.latLng);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Hospital {
  final String placeId;
  final String name;
  final LatLng latLng;
  final double? rating;
  final String address;
  final double distanceMeters;

  _Hospital({
    required this.placeId,
    required this.name,
    required this.latLng,
    required this.rating,
    required this.address,
    required this.distanceMeters,
  });
}
