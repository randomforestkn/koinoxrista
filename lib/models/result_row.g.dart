// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_row.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResultRowAdapter extends TypeAdapter<ResultRow> {
  @override
  final int typeId = 2;

  @override
  ResultRow read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResultRow(
      apartment: fields[0] as Apartment,
      mills: fields[1] as double,
      shareFixed: fields[2] as double,
      shareExtra: fields[3] as double,
      shareElevator: fields[4] as double,
      shareHeating: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ResultRow obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.apartment)
      ..writeByte(1)
      ..write(obj.mills)
      ..writeByte(2)
      ..write(obj.shareFixed)
      ..writeByte(3)
      ..write(obj.shareExtra)
      ..writeByte(4)
      ..write(obj.shareElevator)
      ..writeByte(5)
      ..write(obj.shareHeating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultRowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultRow _$ResultRowFromJson(Map<String, dynamic> json) => ResultRow(
      apartment: Apartment.fromJson(json['apartment'] as Map<String, dynamic>),
      mills: (json['mills'] as num).toDouble(),
      shareFixed: (json['shareFixed'] as num).toDouble(),
      shareExtra: (json['shareExtra'] as num).toDouble(),
      shareElevator: (json['shareElevator'] as num).toDouble(),
      shareHeating: (json['shareHeating'] as num).toDouble(),
    );

Map<String, dynamic> _$ResultRowToJson(ResultRow instance) => <String, dynamic>{
      'apartment': instance.apartment,
      'mills': instance.mills,
      'shareFixed': instance.shareFixed,
      'shareExtra': instance.shareExtra,
      'shareElevator': instance.shareElevator,
      'shareHeating': instance.shareHeating,
    };
