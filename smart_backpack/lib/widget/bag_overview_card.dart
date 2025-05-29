import 'package:flutter/material.dart';
import 'dart:math';

class BagOverviewCard extends StatefulWidget {
  const BagOverviewCard({
    super.key, 
    required this.orientation,
    this.unknownAngle = pi/4, // Default 45 degrees for unknown
  });

  final String orientation;
  final double unknownAngle;

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
    final upperOrientation = orientation.toUpperCase();
    const angleMap = {
      'VERTICAL': 0.0,
      'HORIZONTAL': pi / 2,
      'UPSIDE_DOWN': pi,
      'UNKNOWN': pi / 4,
      '45° ANGLE': pi / 4,
    };
    return angleMap[upperOrientation] ?? 0.0;
  }

  Color getOrientationColor(String orientation) {
    // No special color for 45° angle - all states use blue
    return Colors.blue;
  }

  String getDisplayText(String orientation) {
    final upperOrientation = orientation.toUpperCase();
    if (upperOrientation == 'UNKNOWN') {
      return '45° ANGLE';
    }
    return upperOrientation;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Text(
            "Backpack Orientation",
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: rotationAngle, end: rotationAngle),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOutQuad,
            builder: (context, angle, child) {
              return Transform.rotate(
                angle: angle,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assests/backpack.png', // Fixed assets path
                    fit: BoxFit.contain,
                    // Removed color tint for angled position
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            getDisplayText(widget.orientation),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Always blue now
            ),
          ),
        ],
      ),
    );
  }
}