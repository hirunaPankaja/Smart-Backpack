import 'package:flutter/material.dart';

class NetWeightWidget extends StatelessWidget {
  final double netWeight;

  const NetWeightWidget({super.key, required this.netWeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // ✅ Adjusted padding
      width: MediaQuery.of(context).size.width * 0.85, // ✅ Increased width
      decoration: BoxDecoration(
        color: netWeight > 8 ? Colors.red.withOpacity(0.3) : Colors.white, // ✅ Dynamic color change
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: netWeight > 8 ? Colors.redAccent.withOpacity(0.2) : Colors.grey.shade200,
            blurRadius: netWeight > 8 ? 10 : 6,
            spreadRadius: netWeight > 8 ? 4 : 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.fitness_center, size: 40, color: netWeight > 8 ? Colors.red : Colors.indigo), // ✅ Dynamic icon color
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${netWeight.toStringAsFixed(2)} kg",
                style: TextStyle(
                  color: netWeight > 8 ? Colors.red : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text("Net Weight", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
