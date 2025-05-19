import 'package:flutter/material.dart';
import 'dart:math'; // Required for rotation
import '../service/firebase_service.dart'; // Ensure Firebase is imported

class BagOverviewCard extends StatefulWidget {
  final String orientation;

  const BagOverviewCard({super.key, required this.orientation});

  @override
  State<BagOverviewCard> createState() => _BagOverviewCardState();
}

class _BagOverviewCardState extends State<BagOverviewCard> {
  String orientation = 'UNKNOWN';
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    fetchOrientationData(); // Fetch rotation data from Firebase
  }

  Future<void> fetchOrientationData() async {
    final String newOrientation = await _firebaseService.getBackpackPosition();
    setState(() {
      orientation = newOrientation;
    });
  }

  double getRotationAngle(String orientation) {
    switch (orientation.toUpperCase()) {
      case 'VERTICAL':
        return 0.0; // No rotation
      case 'HORIZONTAL':
        return pi / 2; // 90 degrees
      case 'UPSIDE_DOWN':
        return pi; // 180 degrees
      default:
        return 0.0; // Default (no rotation)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Center everything
        children: [
          // Backpack Orientation Title (Moved Above the Image)
          const Text(
            "Backpack Orientation",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10), // Space before image

          // Backpack Image (Bigger Size & Rotatable)
          Center(
            child: Transform.rotate(
              angle: getRotationAngle(orientation),
              child: Image.asset('assests/backpack.png', width: 80, height: 80), // Increased size
            ),
          ),
          const SizedBox(height: 10), // Space between image & orientation text

          // Firebase Orientation Display (Centered Below Image)
          Text(
            orientation.toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
