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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Battery ${(batteryLevel * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (isCharging)
                const Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Charging',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: batteryLevel,
            backgroundColor: Colors.grey[300],
            color: _getBatteryColor(batteryLevel),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(double level) {
    if (level < 0.2) return Colors.red;
    if (level < 0.5) return Colors.orange;
    return Colors.green;
  }
}