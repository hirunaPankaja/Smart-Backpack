// firebase_service.dart
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<String> getBackpackPosition() async {
    final snapshot = await _dbRef.child('backpack/position').get();
    return snapshot.value?.toString() ?? 'UNKNOWN';
  }

  Future<bool> getWaterLeakStatus() async {
    final snapshot = await _dbRef.child('water-leak-detection/water-leak').get();
    return snapshot.value == true;
  }

  Future<Map<String, dynamic>> getPressureData() async {
    final snapshot = await _dbRef.child('pressure').get();
    final data = snapshot.value as Map?;
    if (data == null) return {};

    return {
      'sensor1': data['sensor1'] ?? 0,
      'sensor2': data['sensor2'] ?? 0,
      'net': data['net'] ?? 0,
    };
  }
}
