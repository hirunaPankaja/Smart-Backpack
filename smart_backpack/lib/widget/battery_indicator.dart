import 'package:flutter/material.dart';

class BatteryIndicator extends StatelessWidget {
  final double batteryLevel;
  final bool isCharging;

  const BatteryIndicator({
    super.key,
    required this.batteryLevel,
    required this.isCharging,
  });

  @override
  Widget build(BuildContext context) {
    // Fix the percentage calculation (divide by 100 if value is > 100)
    final displayLevel = batteryLevel > 100 ? batteryLevel / 100 : batteryLevel;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCharging ? Icons.battery_charging_full : Icons.battery_full,
            color: displayLevel < 20 ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            '${displayLevel.toStringAsFixed(0)}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}