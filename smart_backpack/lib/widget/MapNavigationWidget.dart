import 'package:flutter/material.dart';
import '../screen/map_scrren.dart';

class MapNavigationWidget extends StatelessWidget {
  const MapNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()), // ✅ Navigate to MapScreen
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 6)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.map, size: 40, color: Colors.blue), // ✅ Map icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Open Map",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 6),
                Text("View live bag location", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
