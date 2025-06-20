// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Building _$BuildingFromJson(Map<String, dynamic> json) => Building(
      apartments: (json['apartments'] as List<dynamic>)
          .map((e) => Apartment.fromJson(e as Map<String, dynamic>))
          .toList(),
      expense: Expense.fromJson(json['expense'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BuildingToJson(Building instance) => <String, dynamic>{
      'apartments': instance.apartments,
      'expense': instance.expense,
    };
