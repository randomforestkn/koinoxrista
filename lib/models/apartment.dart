import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'apartment.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Apartment {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final double area;

  @HiveField(2)
  final int floor;

  @HiveField(3)
  final bool elevatorExcluded;

  @HiveField(4)
  final double? customMill;

  const Apartment({
    required this.id,
    required this.area,
    required this.floor,
    this.elevatorExcluded = false,
    this.customMill,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) =>
      _$ApartmentFromJson(json);
  Map<String, dynamic> toJson() => _$ApartmentToJson(this);
}
