import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'apartment.dart';

part 'result_row.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class ResultRow {
  @HiveField(0)
  final Apartment apartment;

  @HiveField(1)
  final double mills;

  @HiveField(2)
  final double shareFixed;

  @HiveField(3)
  final double shareExtra;

  @HiveField(4)
  final double shareElevator;

  @HiveField(5)
  final double shareHeating;

  const ResultRow({
    required this.apartment,
    required this.mills,
    required this.shareFixed,
    required this.shareExtra,
    required this.shareElevator,
    required this.shareHeating,
  });

  double get total => shareFixed + shareExtra + shareElevator + shareHeating;

  factory ResultRow.fromJson(Map<String, dynamic> json) =>
      _$ResultRowFromJson(json);
  Map<String, dynamic> toJson() => _$ResultRowToJson(this);
}
