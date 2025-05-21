import 'package:flutter/material.dart';
import '../dialogs/pressure_adjustment_popup.dart';

class InsideBagPressureWidget extends StatefulWidget {
  final double insidePressure;

  const InsideBagPressureWidget({super.key, required this.insidePressure});

  @override
  _InsideBagPressureWidgetState createState() => _InsideBagPressureWidgetState();
}

class _InsideBagPressureWidgetState extends State<InsideBagPressureWidget> {
  late double currentPressure;

  @override
  void initState() {
    super.initState();
    currentPressure = widget.insidePressure;
  }

  void updatePressure(double newPressure) {
    setState(() {
      currentPressure = newPressure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final adjustedPressure = await showDialog(
          context: context,
          builder: (context) => PressureAdjustmentPopup(
            initialPressure: currentPressure,
            onPressureChanged: updatePressure, // ✅ Live update callback
          ),
        );
        if (adjustedPressure != null) {
          updatePressure(adjustedPressure);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400), // ✅ Smooth animation
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // ✅ Adjusted padding for better spacing
        width: MediaQuery.of(context).size.width * 0.85, // ✅ Increased width
        decoration: BoxDecoration(
          color: currentPressure > 5 ? Colors.red.withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: currentPressure > 5 ? Colors.redAccent.withOpacity(0.5) : Colors.grey.shade200,
              blurRadius: currentPressure > 5 ? 10 : 6,
              spreadRadius: currentPressure > 5 ? 4 : 1,
            ),
          ],
        ),
        child: Row( // ✅ Ensured icon placement inside a row
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 40 + (currentPressure * 2), // ✅ Icon slightly grows with pressure
              height: 40 + (currentPressure * 2),
              child: Icon(Icons.device_thermostat, size: 30, color: currentPressure > 5 ? Colors.red : Colors.blue),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${currentPressure.toStringAsFixed(2)} kg",
                  style: TextStyle(
                    color: currentPressure > 5 ? Colors.red : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text("Inside Bag Pressure", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
