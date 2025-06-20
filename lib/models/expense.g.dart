// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 1;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      fixed: fields[0] as double,
      extra: fields[1] as double,
      elevator: fields[2] as double,
      heating: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.fixed)
      ..writeByte(1)
      ..write(obj.extra)
      ..writeByte(2)
      ..write(obj.elevator)
      ..writeByte(3)
      ..write(obj.heating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      fixed: (json['fixed'] as num).toDouble(),
      extra: (json['extra'] as num).toDouble(),
      elevator: (json['elevator'] as num).toDouble(),
      heating: (json['heating'] as num).toDouble(),
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'fixed': instance.fixed,
      'extra': instance.extra,
      'elevator': instance.elevator,
      'heating': instance.heating,
    };
