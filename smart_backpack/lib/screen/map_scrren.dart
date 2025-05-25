// lib/screens/map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../service/firebase_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final FirebaseService _firebaseService = FirebaseService();
  LatLng? _currentPosition;
  LatLng? _bagPosition;
  Circle? _circle;
  static const double safeRadius = 30;

  StreamSubscription<Map<String, double>?>? _bagStreamSub;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _listenToBagPosition();
  }

  @override
  void dispose() {
    _bagStreamSub?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    final permission = await _checkLocationPermission();
    if (!permission) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _circle = Circle(
        circleId: const CircleId('safe_zone'),
        center: _currentPosition!,
        radius: safeRadius,
        fillColor: Colors.green.withOpacity(0.2),
        strokeColor: Colors.green,
        strokeWidth: 2,
      );
    });
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  void _listenToBagPosition() {
    _bagStreamSub = _firebaseService.bagPositionStream().listen((data) {
      if (data != null) {
        setState(() {
          _bagPosition = LatLng(data['latitude']!, data['longitude']!);
        });
      }
    });
  }

  bool isBagInSafeZone() {
    if (_bagPosition == null || _currentPosition == null) return false;
    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _bagPosition!.latitude,
      _bagPosition!.longitude,
    );
    return distance <= safeRadius;
  }

  String getStatusText() {
    if (_bagPosition == null) return "Bag location not found.";
    return isBagInSafeZone() ? "🎒 Bag is with you (within safe zone)." : "⚠️ Bag is misplaced! Tap to locate.";
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_currentPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('me'),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "You"),
      ));
    }
    if (_bagPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('bag'),
        position: _bagPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "Bag"),
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return const Scaffold(body: Center(child: Text("Google Maps API Key not found.")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Positioned.fill(
            child: ClipOval(
              child: _currentPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 18,
                      ),
                      markers: _buildMarkers(),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      circles: _circle != null ? {_circle!} : {},
                      onMapCreated: (controller) => _controller.complete(controller),
                    ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(getStatusText(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  if (_bagPosition != null && !isBagInSafeZone())
                    ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text("Navigate to Bag"),
                      onPressed: () async {
                        final controller = await _controller.future;
                        controller.animateCamera(CameraUpdate.newLatLng(_bagPosition!));
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
