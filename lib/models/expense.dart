import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Expense {
  @HiveField(0)
  final double fixed;

  @HiveField(1)
  final double extra;

  @HiveField(2)
  final double elevator;

  @HiveField(3)
  final double heating;

  const Expense({
    required this.fixed,
    required this.extra,
    required this.elevator,
    required this.heating,
  });

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
