import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import '../models/pressure_data.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Hive box for storing pressure history
  late final Box<PressureData> _pressureBox;

  FirebaseService() {
    _initHiveBox();
  }

  Future<void> _initHiveBox() async {
    // Open the Hive box for pressure data storage
    _pressureBox = await Hive.openBox<PressureData>('pressure_data');
  }

  // Real-time listeners
  DatabaseReference getPositionRef() => _dbRef.child('backpack/position');
  DatabaseReference getWaterLeakRef() => _dbRef.child('water-leak-detection/water-leak');
  DatabaseReference getPressureRef() => _dbRef.child('pressure');
  DatabaseReference getCardsRef() => _dbRef.child('cards');
  DatabaseReference getBatteryRef() => _dbRef.child('battery');
  DatabaseReference getBagPositionRef() => _dbRef.child('gps');
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

  // ------------------- NEW FUNCTIONS -------------------

  /// Starts listening to pressure updates and saves each data point locally with timestamp.
  /// Call this once during app initialization.
  void startPressureHistoryListener() {
    getPressureRef().onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      // If the data is nested under a 'pressure' key, extract it
      final pressureMap = data.containsKey('pressure') ? data['pressure'] as Map? : data;

      if (pressureMap == null) return;

      final left = (pressureMap['sensor1'] ?? 0).toDouble();
      final right = (pressureMap['sensor2'] ?? 0).toDouble();
      final net = (pressureMap['net'] ?? 0).toDouble();

      final pressureData = PressureData(
      timestamp: DateTime.now(),
      left: left,
      right: right,
      net: net,
      );

      _pressureBox.add(pressureData);
    });
  }

  /// Returns the list of stored pressure data points.
  List<PressureData> getPressureHistory() {
    return _pressureBox.values.toList();
  }
}
