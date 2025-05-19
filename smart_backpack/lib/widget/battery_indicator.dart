// battery_indicator.dart
import 'package:flutter/material.dart';

class BatteryIndicator extends StatelessWidget {
  final double batteryLevel;

  const BatteryIndicator({super.key, required this.batteryLevel});

  @override
  Widget build(BuildContext context) {
    return Text("Battery: ${(batteryLevel * 100).toStringAsFixed(0)}%");
  }
}
