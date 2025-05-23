import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapScreen extends StatefulWidget {
    const MapScreen({Key? key}) : super(key: key);

    @override
    State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
    Completer<GoogleMapController> _controller = Completer();
    LatLng? _currentPosition;
    Circle? _circle;

    @override
    void initState() {
        super.initState();
        _loadCurrentLocation();
    }

    Future<void> _loadCurrentLocation() async {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
            await Geolocator.openLocationSettings();
            return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
                return;
            }
        }

        if (permission == LocationPermission.deniedForever) {
            return;
        }

        Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);

        setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
            _circle = Circle(
                circleId: CircleId('current_location_circle'),
                center: _currentPosition!,
                radius: 10, // meters
                fillColor: Colors.blue.withOpacity(0.3),
                strokeColor: Colors.blue,
                strokeWidth: 2,
            );
        });
    }

    @override
    Widget build(BuildContext context) {
        final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
        if (apiKey == null) {
            return const Center(child: Text('Google Maps API key not found.'));
        }

        return Scaffold(
            appBar: AppBar(
                title: const Text('Map'),
            ),
            body: _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: _currentPosition!,
                                zoom: 18,
                            ),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            circles: _circle != null ? {_circle!} : {},
                            onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                            },
                        ),
        );
    }
}