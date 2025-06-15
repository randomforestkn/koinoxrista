// lib/services/calculation_service.dart

import '../models/building.dart';
import '../models/result_row.dart';

class CalculationService {
  /// Υπολογίζει τα κοινόχρηστα και επιστρέφει λίστα αποτελεσμάτων ανά διαμέρισμα.
  /// Throws [ArgumentError] εάν τα δεδομένα είναι μη έγκυρα.
  List<ResultRow> calculateShares(Building building) {
    _validate(building);

    // 1. Υπολογισμός χιλιοστών με υποστήριξη customMill
    final mills = <int, double>{};
    double customSum = 0.0;
    double nonCustomTotalArea = 0.0;

    for (final a in building.apartments) {
      if (a.customMill != null) {
        mills[a.id] = a.customMill!;
        customSum += a.customMill!;
      } else {
        nonCustomTotalArea += a.area;
      }
    }

    final remainingMill = 1.0 - customSum;
    for (final a in building.apartments) {
      if (a.customMill == null) {
        if (nonCustomTotalArea == 0) {
          mills[a.id] = 0;
        } else {
          mills[a.id] = remainingMill * (a.area / nonCustomTotalArea);
        }
      }
    }

    // 2. Κατανομή πάγιων & έκτακτων
    final C_fixed = building.expense.fixed;
    final C_extra = building.expense.extra;

    // 3. Έγκυρα διαμερίσματα για ανελκυστήρα
    final elevatorEligible = building.apartments.where((a) => !a.elevatorExcluded).toList();
    final totalMillsElevator = elevatorEligible.fold<double>(0.0, (s, a) => s + mills[a.id]!);

    // 4. Συντελεστής ορόφου kF (ενδεικτικές τιμές)
    double kF(int floor, int maxFloor) {
      if (floor < 0) return 0.55; // υπόγειο
      if (floor == 0) return 0.75; // ισόγειο
      return floor == maxFloor ? 1.20 : 1.0;
    }

    final maxFloor = building.apartments.map((a) => a.floor).reduce((a, b) => a > b ? a : b);
    final kFMap = <int, double>{};
    double totalKFWeightedArea = 0.0;
    for (final a in building.apartments) {
      final coef = kF(a.floor, maxFloor);
      kFMap[a.id] = coef;
      totalKFWeightedArea += coef * a.area;
    }

    // 5. Δημιουργία αποτελεσμάτων
    final results = <ResultRow>[];
    for (final a in building.apartments) {
      final mill = mills[a.id]!;
      final double shareFixed = mill * C_fixed;
      final double shareExtra = mill * C_extra;
      final double shareElevator = (a.elevatorExcluded || building.expense.elevator == 0 || totalMillsElevator == 0)
          ? 0.0
          : (mill / totalMillsElevator) * building.expense.elevator;
      final double shareHeating = (building.expense.heating == 0 || totalKFWeightedArea == 0)
          ? 0.0
          : (kFMap[a.id]! * a.area / totalKFWeightedArea) * building.expense.heating;

      results.add(ResultRow(
        apartment: a,
        mills: mill,
        shareFixed: shareFixed,
        shareExtra: shareExtra,
        shareElevator: shareElevator,
        shareHeating: shareHeating,
      ));
    }

    return results;
  }

  void _validate(Building building) {
    if (building.apartments.isEmpty) {
      throw ArgumentError('Πρέπει να υπάρχει τουλάχιστον ένα διαμέρισμα');
    }
    if (building.expense.fixed < 0 ||
        building.expense.extra < 0 ||
        building.expense.elevator < 0 ||
        building.expense.heating < 0) {
      throw ArgumentError('Τα έξοδα δεν μπορεί να είναι αρνητικά');
    }
    final sumCustomMills = building.apartments
        .where((a) => a.customMill != null)
        .fold<double>(0.0, (s, a) => s + a.customMill!);
    if (sumCustomMills > 1.0 + 1e-9) {
      throw ArgumentError('Το άθροισμα των custom χιλιοστών υπερβαίνει το 100%.');
    }
  }
}
