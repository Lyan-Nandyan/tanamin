// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantScheduleAdapter extends TypeAdapter<PlantSchedule> {
  @override
  final int typeId = 0;

  @override
  PlantSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlantSchedule(
      id: fields[0] as int,
      hour: fields[1] as int,
      minute: fields[2] as int,
      repeatDays: (fields[3] as List).cast<int>(),
      title: fields[4] as String,
      body: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlantSchedule obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.hour)
      ..writeByte(2)
      ..write(obj.minute)
      ..writeByte(3)
      ..write(obj.repeatDays)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.body);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
