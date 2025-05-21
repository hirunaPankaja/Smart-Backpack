import 'package:flutter/material.dart';

class PressureAdjustmentPopup extends StatefulWidget {
  final double initialPressure;
  final Function(double) onPressureChanged;

  const PressureAdjustmentPopup({super.key, required this.initialPressure, required this.onPressureChanged});

  @override
  _PressureAdjustmentPopupState createState() => _PressureAdjustmentPopupState();
}

class _PressureAdjustmentPopupState extends State<PressureAdjustmentPopup> {
  late double pressureValue;

  @override
  void initState() {
    super.initState();
    pressureValue = widget.initialPressure;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Adjust Inside Bag Pressure"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ✅ Animated Circle Around Temperature Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: pressureValue * 12 + 50, // ✅ Circle expands based on pressure
            height: pressureValue * 12 + 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pressureValue > 5 ? Colors.red.withOpacity(0.4) : Colors.blue.withOpacity(0.4), // ✅ Dynamic color shift
              boxShadow: [
                BoxShadow(
                  color: pressureValue > 5 ? Colors.redAccent.withOpacity(0.6) : Colors.blueAccent.withOpacity(0.6),
                  blurRadius: pressureValue * 3,
                  spreadRadius: pressureValue / 2, // ✅ Glow effect
                ),
              ],
            ),
            child: Center(
              child: Icon(Icons.device_thermostat, size: 40, color: pressureValue > 5 ? Colors.red : Colors.blue),
            ),
          ),
          const SizedBox(height: 12),

          Text("Current Pressure: ${pressureValue.toStringAsFixed(2)} kg", style: const TextStyle(fontSize: 16)),

          /// ✅ Slider with Real-Time Animation Updates
          Slider(
            min: 0,
            max: 10,
            value: pressureValue,
            onChanged: (value) {
              setState(() {
                pressureValue = value; // ✅ Only affects popup animation
                widget.onPressureChanged(value);
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, pressureValue), // ✅ Pass updated value back
          child: const Text("Save"),
        ),
      ],
    );
  }
}
