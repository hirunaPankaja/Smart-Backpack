import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import '../models/pressure_data.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late final Box<PressureData> _pressureBox;
  bool _isInitialized = false;

  FirebaseService() {
    _initHiveBox();
  }

  Future<void> _initHiveBox() async {
    if (!_isInitialized) {
      _pressureBox = await Hive.openBox<PressureData>('pressure_data');
      _isInitialized = true;
    }
  }

  // Real-time listeners (existing methods)
  DatabaseReference getPositionRef() => _dbRef.child('backpack/position');
  DatabaseReference getWaterLeakRef() => _dbRef.child('water-leak-detection/water-leak');
  DatabaseReference getPressureRef() => _dbRef.child('pressure');
  DatabaseReference getCardsRef() => _dbRef.child('cards');
  DatabaseReference getBatteryRef() => _dbRef.child('battery');
  DatabaseReference getBagPositionRef() => _dbRef.child('gps');
  DatabaseReference getTemperatureRef() => _dbRef.child('sensorData/temperature');
  DatabaseReference getHumidityRef() => _dbRef.child('sensorData/humidity');

  // PRESSURE DATA METHODS - NEW IMPLEMENTATION

  /// Stream real-time pressure data from Firebase and save to local storage
  Stream<PressureData> pressureDataStream() {
    return getPressureRef().onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      
      if (data == null) {
        return PressureData(
          timestamp: DateTime.now(),
          left: 0,
          right: 0,
          net: 0,
        );
      }

      final pressureData = PressureData(
        timestamp: DateTime.now(),
        left: (data['left'] ?? 0).toDouble(),
        right: (data['right'] ?? 0).toDouble(),
        net: ((data['left'] ?? 0) - (data['right'] ?? 0)).toDouble(),
      );

      // Save to local storage automatically
      _savePressureDataLocally(pressureData);
      
      return pressureData;
    });
  }

  /// Save pressure data to local Hive storage
  Future<void> _savePressureDataLocally(PressureData data) async {
    await _ensureInitialized();
    
    try {
      // Add timestamp as key to maintain order
      final key = data.timestamp.millisecondsSinceEpoch.toString();
      await _pressureBox.put(key, data);
      
      // Keep only last 1000 records to prevent storage bloat
      if (_pressureBox.length > 1000) {
        final oldestKey = _pressureBox.keys.first;
        await _pressureBox.delete(oldestKey);
      }
    } catch (e) {
      print('Error saving pressure data locally: $e');
    }
  }

  /// Get stored pressure history from local storage
  List<PressureData> getPressureHistory({int? limitHours}) {
    if (!_isInitialized || _pressureBox.isEmpty) return [];

    List<PressureData> allData = _pressureBox.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (limitHours != null) {
      final cutoffTime = DateTime.now().subtract(Duration(hours: limitHours));
      allData = allData.where((data) => data.timestamp.isAfter(cutoffTime)).toList();
    }

    return allData;
  }

  /// Get pressure analytics for the specified time period
  PressureAnalytics getPressureAnalytics({int hours = 24}) {
    final data = getPressureHistory(limitHours: hours);
    
    if (data.isEmpty) {
      return PressureAnalytics(
        leftAvg: 0,
        rightAvg: 0,
        leftMax: 0,
        rightMax: 0,
        dominantSide: 'balanced',
        imbalancePercentage: 0,
        totalReadings: 0,
        timeSpan: hours,
        recommendations: ['Start monitoring to get personalized tips'],
      );
    }

    final leftValues = data.map((d) => d.left).toList();
    final rightValues = data.map((d) => d.right).toList();

    final leftAvg = leftValues.reduce((a, b) => a + b) / leftValues.length;
    final rightAvg = rightValues.reduce((a, b) => a + b) / rightValues.length;
    final leftMax = leftValues.reduce((a, b) => a > b ? a : b);
    final rightMax = rightValues.reduce((a, b) => a > b ? a : b);

    final imbalance = (leftAvg - rightAvg).abs();
    final totalAvg = (leftAvg + rightAvg) / 2;
    final imbalancePercentage = totalAvg > 0 ? (imbalance / totalAvg) * 100 : 0;

    String dominantSide;
    if (imbalancePercentage < 10) {
      dominantSide = 'balanced';
    } else if (leftAvg > rightAvg) {
      dominantSide = 'left';
    } else {
      dominantSide = 'right';
    }

    return PressureAnalytics(
      leftAvg: leftAvg,
      rightAvg: rightAvg,
      leftMax: leftMax,
      rightMax: rightMax,
      dominantSide: dominantSide,
      imbalancePercentage: imbalancePercentage.toDouble(),
      totalReadings: data.length,
      timeSpan: hours,
      recommendations: _generateRecommendations(dominantSide, imbalancePercentage.toDouble(), leftAvg, rightAvg),
    );
  }

  /// Generate dynamic recommendations based on pressure patterns
  List<String> _generateRecommendations(String dominantSide, double imbalancePercentage, double leftAvg, double rightAvg) {
    List<String> tips = [];

    // Imbalance recommendations
    if (imbalancePercentage > 30) {
      if (dominantSide == 'left') {
        tips.add('⚠️ High left-side pressure detected! Adjust your backpack straps or redistribute weight to the right.');
        tips.add('💡 Try moving heavier items to the right side of your bag.');
      } else if (dominantSide == 'right') {
        tips.add('⚠️ High right-side pressure detected! Adjust your backpack straps or redistribute weight to the left.');
        tips.add('💡 Try moving heavier items to the left side of your bag.');
      }
    } else if (imbalancePercentage > 15) {
      tips.add('🔄 Moderate pressure imbalance. Consider adjusting your bag position occasionally.');
    } else {
      tips.add('✅ Good pressure balance! Keep maintaining this posture.');
    }

    // Overall pressure recommendations
    final totalPressure = leftAvg + rightAvg;
    if (totalPressure > 2000) { // High pressure (over 2kg total)
      tips.add('🎒 Heavy load detected! Consider removing non-essential items to reduce strain.');
      tips.add('🚶‍♂️ Take regular breaks to relieve pressure on your shoulders.');
    } else if (totalPressure > 1000) { // Moderate pressure (1-2kg total)
      tips.add('👍 Moderate load - ensure straps are properly adjusted for comfort.');
    } else {
      tips.add('🌟 Light load detected - perfect for extended carrying!');
    }

    // Time-based recommendations
    tips.add('⏰ Monitor throughout the day to maintain optimal weight distribution.');

    return tips;
  }

  /// Clear all stored pressure data
  Future<void> clearPressureHistory() async {
    await _ensureInitialized();
    await _pressureBox.clear();
  }

  /// Get current pressure reading (one-time fetch)
  Future<PressureData> getCurrentPressure() async {
    final snapshot = await getPressureRef().get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) {
      return PressureData(
        timestamp: DateTime.now(),
        left: 0,
        right: 0,
        net: 0,
      );
    }

    return PressureData(
      timestamp: DateTime.now(),
      left: (data['left'] ?? 0).toDouble(),
      right: (data['right'] ?? 0).toDouble(),
      net: ((data['left'] ?? 0) - (data['right'] ?? 0)).toDouble(),
    );
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initHiveBox();
    }
  }

  // Existing methods remain unchanged...
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
      'left': data['left'] ?? 0,
      'right': data['right'] ?? 0,
      'center': data['center'] ?? 0,
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

// Analytics model
class PressureAnalytics {
  final double leftAvg;
  final double rightAvg;
  final double leftMax;
  final double rightMax;
  final String dominantSide;
  final double imbalancePercentage;
  final int totalReadings;
  final int timeSpan;
  final List<String> recommendations;

  PressureAnalytics({
    required this.leftAvg,
    required this.rightAvg,
    required this.leftMax,
    required this.rightMax,
    required this.dominantSide,
    required this.imbalancePercentage,
    required this.totalReadings,
    required this.timeSpan,
    required this.recommendations,
  });
}