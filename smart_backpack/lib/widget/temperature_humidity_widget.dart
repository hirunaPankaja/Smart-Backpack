import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../service/firebase_service.dart'; // ✅ Import FirebaseService

class TemperatureHumidityWidget extends StatefulWidget {
  final Function(double, double) onDataReceived; // ✅ Callback to send data

  const TemperatureHumidityWidget({super.key, required this.onDataReceived});

  @override
  _TemperatureHumidityWidgetState createState() => _TemperatureHumidityWidgetState();
}

class _TemperatureHumidityWidgetState extends State<TemperatureHumidityWidget> {
  final FirebaseService _firebaseService = FirebaseService(); // ✅ Use FirebaseService
  late DatabaseReference _temperatureRef;
  late DatabaseReference _humidityRef;
  double temperature = 0.0;
  double humidity = 0.0;

  @override
  void initState() {
    super.initState();
    _setupRealTimeListeners();
  }

  void _setupRealTimeListeners() {
    _temperatureRef = _firebaseService.getTemperatureRef();
    _humidityRef = _firebaseService.getHumidityRef();

    _temperatureRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          temperature = double.tryParse(data.toString()) ?? 0.0;
          widget.onDataReceived(temperature, humidity); // ✅ Send updated values
        });
      }
    });

    _humidityRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          humidity = double.tryParse(data.toString()) ?? 0.0;
          widget.onDataReceived(temperature, humidity); // ✅ Send updated values
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // ✅ No UI, only sends data
  }
}