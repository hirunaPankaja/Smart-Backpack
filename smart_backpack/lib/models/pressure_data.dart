import 'package:hive/hive.dart';

part 'pressure_data.g.dart';

@HiveType(typeId: 0)
class PressureData extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;



  @HiveField(1)
  final double left;

  @HiveField(2)
  final double right;

  @HiveField(3)
  final double net;



  PressureData({
    required this.timestamp,
    required this.left,
    required this.right,
    required this.net, 
  });
}
