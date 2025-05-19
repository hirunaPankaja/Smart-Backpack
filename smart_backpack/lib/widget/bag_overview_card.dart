import 'package:flutter/material.dart';

class BagOverviewCard extends StatelessWidget {
  final String orientation;

  const BagOverviewCard({super.key, required this.orientation});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color bgColor;

    // Example logic – feel free to change based on your backend data
    switch (orientation.toUpperCase()) {
      case 'VERTICAL':
        iconData = Icons.swap_vert;
        bgColor = Colors.green;
        break;
      case 'HORIZONTAL':
        iconData = Icons.swap_horiz;
        bgColor = Colors.orange;
        break;
      default:
        iconData = Icons.help_outline;
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(iconData, size: 48, color: bgColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Backpack Orientation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(orientation, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
