import 'package:flutter/material.dart';
import 'dart:math';
import '../service/firebase_service.dart';

class BagOverviewCard extends StatefulWidget {
  const BagOverviewCard({super.key, required this.orientation});

  final String orientation;

  @override
  State<BagOverviewCard> createState() => _BagOverviewCardState();
}

class _BagOverviewCardState extends State<BagOverviewCard> {
  double rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
    rotationAngle = getRotationAngle(widget.orientation);
  }

  @override
  void didUpdateWidget(covariant BagOverviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orientation != widget.orientation) {
      setState(() {
        rotationAngle = getRotationAngle(widget.orientation);
      });
    }
  }

  double getRotationAngle(String orientation) {
    switch (orientation.toUpperCase()) {
      case 'VERTICAL':
        return 0.0;
      case 'HORIZONTAL':
        return pi / 2;
      case 'UPSIDE_DOWN':
        return pi;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10), // Moves title slightly up
          const Text(
            "Backpack Orientation",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20), // Adds space before backpack
          // ✅ Smooth rotation with visible motion effect
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: rotationAngle, end: rotationAngle),
            duration: const Duration(
              milliseconds: 1200,
            ), // ✅ Slower, smoother motion
            curve: Curves.easeInOutQuad, // ✅ Natural easing transition
            builder: (context, angle, child) {
              return Transform.rotate(
                angle: angle,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assests/backpack.png',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20), // Extra spacing for clarity

          Text(
            widget.orientation.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
