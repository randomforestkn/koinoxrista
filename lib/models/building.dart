import 'package:json_annotation/json_annotation.dart';

import 'apartment.dart';
import 'expense.dart';

part 'building.g.dart';

@JsonSerializable()
class Building {
  final List<Apartment> apartments;
  final Expense expense;

  const Building({required this.apartments, required this.expense});

  factory Building.fromJson(Map<String, dynamic> json) =>
      _$BuildingFromJson(json);
  Map<String, dynamic> toJson() => _$BuildingToJson(this);
}
