import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class InsideBagPressureWidget extends StatefulWidget {
  const InsideBagPressureWidget({super.key});

  @override
  _InsideBagPressureWidgetState createState() => _InsideBagPressureWidgetState();
}

class _InsideBagPressureWidgetState extends State<InsideBagPressureWidget> {
  double _centerPressure = 0.0;
  bool _isLoading = true;
  bool _hasError = false;

  final DatabaseReference _pressureRef = 
      FirebaseDatabase.instance.ref().child('pressure/center');

  @override
  void initState() {
    super.initState();
    _initializePressureMonitoring();
  }

  Future<void> _initializePressureMonitoring() async {
    try {
      // Initial fetch
      final snapshot = await _pressureRef.get();
      _updatePressure(snapshot);

      // Set up real-time listener
      _pressureRef.onValue.listen((event) {
        _updatePressure(event.snapshot);
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('Pressure monitoring error: $e');
    }
  }

  void _updatePressure(DataSnapshot snapshot) {
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
      _centerPressure = double.tryParse(snapshot.value.toString()) ?? _centerPressure;
      _hasError = false;
    });
  }

  Color get _pressureColor {
    if (_hasError) return Colors.orange;
    if (_centerPressure > 7) return Colors.red;
    if (_centerPressure > 5) return Colors.orange;
    return Colors.blue;
  }

  double get _visualSize {
    return 40 + (_centerPressure * 2).clamp(0, 30);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: _pressureColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _pressureColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _pressureColor.withOpacity(0.2),
            blurRadius: _centerPressure > 5 ? 10 : 6,
            spreadRadius: _centerPressure > 5 ? 4 : 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: _visualSize,
            height: _visualSize,
            child: _isLoading 
                ? const CircularProgressIndicator(strokeWidth: 3)
                : Icon(
                    _hasError ? Icons.error_outline : Icons.device_thermostat,
                    size: 30,
                    color: _pressureColor,
                  ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _hasError 
                    ? "Error" 
                    : "${_centerPressure.toStringAsFixed(2)} kg",
                style: TextStyle(
                  color: _pressureColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _hasError ? "Failed to load data" : "Center Bag Pressure",
                style: TextStyle(
                  color: Colors.grey[600], 
                  fontSize: 14
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}