// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pressure_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PressureDataAdapter extends TypeAdapter<PressureData> {
  @override
  final int typeId = 0;

  @override
  PressureData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PressureData(
      timestamp: fields[0] as DateTime,
      left: fields[1] as double,
      right: fields[2] as double,
      net: fields[3] as double,
      
    );
  }

  @override
  void write(BinaryWriter writer, PressureData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.left)
      ..writeByte(2)
      ..write(obj.right)
      ..writeByte(3)
      ..write(obj.net);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PressureDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
