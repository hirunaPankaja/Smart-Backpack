import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Real-time listeners
  DatabaseReference getPositionRef() => _dbRef.child('backpack/position');
  DatabaseReference getWaterLeakRef() => _dbRef.child('water-leak-detection/water-leak');
  DatabaseReference getPressureRef() => _dbRef.child('pressure');
  DatabaseReference getCardsRef() => _dbRef.child('cards');
  DatabaseReference getBatteryRef() => _dbRef.child('battery');
  DatabaseReference getBagPositionRef() => _dbRef.child('neo6m');
  DatabaseReference getTemperatureRef() => _dbRef.child('sensorData/temperature'); // ✅ Corrected path
  DatabaseReference getHumidityRef() => _dbRef.child('sensorData/humidity'); // ✅ Added humidity reference

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
  Stream<Map<String, double>?> bagPositionStream() {
    return getBagPositionRef().onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return null;

      final latitude = double.tryParse(data['latitude'].toString());
      final longitude = double.tryParse(data['longitude'].toString());

      if (latitude != null && longitude != null) {
        return {'latitude': latitude, 'longitude': longitude};
      }
      return null;
    });
  }
}