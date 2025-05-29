import 'dart:async';
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
  bool _isEditing = false;
  TextEditingController _pressureController = TextEditingController();
  StreamSubscription<DatabaseEvent>? _pressureSubscription;

  final DatabaseReference _pressureRef = 
      FirebaseDatabase.instance.ref().child('pressure/center');

  @override
  void initState() {
    super.initState();
    _initializePressureMonitoring();
    _pressureController = TextEditingController();
  }

  @override
  void dispose() {
    _pressureSubscription?.cancel();
    _pressureController.dispose();
    super.dispose();
  }

  Future<void> _initializePressureMonitoring() async {
    try {
      // Initial fetch
      final snapshot = await _pressureRef.get();
      if (!mounted) return;
      _updatePressure(snapshot);

      // Set up real-time listener
      _pressureSubscription = _pressureRef.onValue.listen((event) {
        if (!mounted) return;
        _updatePressure(event.snapshot);
      }, onError: (error) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('Pressure monitoring error: $e');
    }
  }

  void _updatePressure(DataSnapshot snapshot) {
    try {
      final newValue = double.tryParse(snapshot.value.toString());
      if (newValue == null) {
        throw Exception('Invalid pressure value: ${snapshot.value}');
      }
      
      setState(() {
        _isLoading = false;
        _centerPressure = newValue;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('Pressure update error: $e');
    }
  }

  Future<void> _updatePressureInFirebase(double newPressure) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _pressureRef.set(newPressure);
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      debugPrint('Failed to update pressure: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
      }
    }
  }

  void _startEditing() {
    _pressureController.text = _centerPressure.toStringAsFixed(2);
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  void _submitNewPressure() {
    final newPressure = double.tryParse(_pressureController.text) ?? _centerPressure;
    _updatePressureInFirebase(newPressure);
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
    return GestureDetector(
      onTap: () {
        if (!_isEditing && !_isLoading && !_hasError) {
          _startEditing();
        }
      },
      child: AnimatedContainer(
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
        child: _isEditing ? _buildEditWidget() : _buildDisplayWidget(),
      ),
    );
  }

  Widget _buildDisplayWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: _visualSize,
          height: _visualSize,
          child: _isLoading 
              ? const CircularProgressIndicator(strokeWidth: 3)
              : _hasError
                  ? const Icon(Icons.error_outline, size: 30, color: Colors.orange)
                  : Icon(
                      Icons.device_thermostat,
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
                  : "${_centerPressure.toStringAsFixed(2)} g",
              style: TextStyle(
                color: _pressureColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _hasError ? "Failed to load data" : "Tap to adjust pressure",
              style: TextStyle(
                color: Colors.grey[600], 
                fontSize: 14
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _pressureController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'New Pressure (g)',
            border: OutlineInputBorder(),
            suffixText: 'g',
            errorText: _hasError ? 'Failed to update' : null,
          ),
          style: TextStyle(
            color: _pressureColor,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _cancelEditing,
              child: Text('Cancel'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _submitNewPressure,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pressureColor,
              ),
              child: Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}