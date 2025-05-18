import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String currentOrientation = 'horizontal'; // sample data

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Smart Backpack',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const BatteryIndicator(batteryLevel: 0.76),
            const SizedBox(height: 20),
            BagOverviewCard(orientation: currentOrientation),
            const SizedBox(height: 20),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: const [
                InfoCard(title: 'Items Detected', icon: Icons.inventory_2, value: '4', iconColor: Colors.orange),
                InfoCard(title: 'Temperature', icon: Icons.thermostat, value: '32°C', iconColor: Colors.redAccent),
                InfoCard(title: 'Last Sync', icon: Icons.update, value: '5 min ago', iconColor: Colors.blue),
                InfoCard(title: 'Water Detect', icon: Icons.water_drop, value: 'None', iconColor: Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BatteryIndicator extends StatelessWidget {
  final double batteryLevel;

  const BatteryIndicator({super.key, required this.batteryLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.battery_full, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: batteryLevel,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 10,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(batteryLevel * 100).toInt()}%',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class BagOverviewCard extends StatelessWidget {
  final String orientation;

  const BagOverviewCard({super.key, required this.orientation});

  IconData _getIconForOrientation(String pos) {
    switch (pos.toLowerCase()) {
      case 'horizontal':
        return Icons.swap_horiz;
      case 'upside':
        return Icons.flip_camera_android;
      default:
        return Icons.backpack;
    }
  }

  String _getLabel(String pos) {
    switch (pos.toLowerCase()) {
      case 'horizontal':
        return 'Horizontal';
      case 'upside':
        return 'Upside Down';
      default:
        return 'Vertical';
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForOrientation(orientation);
    final label = _getLabel(orientation);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.black),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final Color iconColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
