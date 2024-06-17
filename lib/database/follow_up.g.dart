// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_up.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FollowUpAdapter extends TypeAdapter<FollowUp> {
  @override
  final int typeId = 6;

  @override
  FollowUp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FollowUp(
      customer: fields[0] as Customer,
      followUpDate: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FollowUp obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.customer)
      ..writeByte(1)
      ..write(obj.followUpDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowUpAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
