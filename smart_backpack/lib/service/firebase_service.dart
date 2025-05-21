import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Real-time listeners
  DatabaseReference getPositionRef() => _dbRef.child('backpack/position');
  DatabaseReference getWaterLeakRef() => _dbRef.child('water-leak-detection/water-leak');
  DatabaseReference getPressureRef() => _dbRef.child('pressure');
  DatabaseReference getCardsRef() => _dbRef.child('cards');
  DatabaseReference getBatteryRef() => _dbRef.child('battery');

  // One-time fetch methods
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

  Future<Map<String, dynamic>> getCardsData() async {
    final snapshot = await _dbRef.child('cards').get();
    final data = snapshot.value as Map?;
    if (data == null) return {};

    return Map<String, dynamic>.from(data);
  }
  

  Future<Map<String, dynamic>> getBatteryData() async {
    final snapshot = await _dbRef.child('battery').get();
    final data = snapshot.value as Map?;
    if (data == null) return {};

    return {
      'level': data['level'] ?? 0,
      'isCharging': data['isCharging'] ?? false,
    };
  }
}