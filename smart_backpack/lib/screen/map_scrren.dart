import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../service/firebase_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  final FirebaseService _firebaseService = FirebaseService();
  LatLng? _currentPosition;
  LatLng? _bagPosition;
  String _bagLocationName = "Unknown Location";

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  StreamSubscription<Map<String, double>?>? _bagStreamSub;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _listenToBagPosition();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _bagStreamSub?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    final permission = await _checkLocationPermission();
    if (!permission) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
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

  Future<String> _getPlaceName(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        return "${placemarks.first.locality}, ${placemarks.first.country}";
      }
    } catch (e) {
      print("Error fetching place name: $e");
    }
    return "Unknown Location";
  }

  void _listenToBagPosition() {
    _bagStreamSub = _firebaseService.bagPositionStream().listen((data) async {
      if (data != null) {
        LatLng newPosition = LatLng(data['latitude']!, data['longitude']!);
        String placeName = await _getPlaceName(newPosition);
        setState(() {
          _bagPosition = newPosition;
          _bagLocationName = placeName;
          _animationController.forward();
        });
      }
    });
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
        infoWindow: InfoWindow(title: _bagLocationName),
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
                    onMapCreated: (controller) => _controller.complete(controller),
                  ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Align(
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
                    Text(
                      _bagPosition == null ? "Bag location not found." : "🎒 Bag is at $_bagLocationName",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    if (_bagPosition != null)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.directions),
                        label: const Text("Navigate to Bag"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final controller = await _controller.future;
                          controller.animateCamera(CameraUpdate.newLatLng(_bagPosition!));
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
