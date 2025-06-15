// lib/models/result_row.dart

import 'apartment.dart';


class ResultRow {
  final Apartment apartment;
  final double mills;
  final double shareFixed;
  final double shareExtra;
  final double shareElevator;
  final double shareHeating;
  double get total => shareFixed + shareExtra + shareElevator + shareHeating;

  const ResultRow({
    required this.apartment,
    required this.mills,
    required this.shareFixed,
    required this.shareExtra,
    required this.shareElevator,
    required this.shareHeating,
  });
}
