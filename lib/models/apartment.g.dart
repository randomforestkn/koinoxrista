// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apartment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApartmentAdapter extends TypeAdapter<Apartment> {
  @override
  final int typeId = 0;

  @override
  Apartment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Apartment(
      id: fields[0] as int,
      area: fields[1] as double,
      floor: fields[2] as int,
      elevatorExcluded: fields[3] as bool,
      customMill: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Apartment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.area)
      ..writeByte(2)
      ..write(obj.floor)
      ..writeByte(3)
      ..write(obj.elevatorExcluded)
      ..writeByte(4)
      ..write(obj.customMill);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApartmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Apartment _$ApartmentFromJson(Map<String, dynamic> json) => Apartment(
      id: (json['id'] as num).toInt(),
      area: (json['area'] as num).toDouble(),
      floor: (json['floor'] as num).toInt(),
      elevatorExcluded: json['elevatorExcluded'] as bool? ?? false,
      customMill: (json['customMill'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ApartmentToJson(Apartment instance) => <String, dynamic>{
      'id': instance.id,
      'area': instance.area,
      'floor': instance.floor,
      'elevatorExcluded': instance.elevatorExcluded,
      'customMill': instance.customMill,
    };
