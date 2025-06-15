/// Simple micro‑benchmark for CalculationService
/// Run with: `dart tool/benchmark.dart` (or `flutter run -d macos tool/benchmark.dart`)

import 'dart:math';
import '../lib/models/apartment.dart';
import '../lib/models/building.dart';
import '../lib/models/expense.dart';
import '../lib/services/calculation_service.dart';

void main() {
  const sizes = [10, 100, 1000, 5000];
  final calc = CalculationService();
  final rand = Random(42);

  for (final n in sizes) {
    final building = _generateBuilding(n, rand);

    final sw = Stopwatch()..start();
    calc.calculateShares(building);
    sw.stop();

    print('n=$n apartments -> ${sw.elapsedMicroseconds} μs');
  }
}

Building _generateBuilding(int n, Random rand) {
  final apartments = List.generate(n, (i) {
    final area = 50 + rand.nextInt(80); // 50‑130 m²
    final floor = rand.nextInt(7); // 0‑6
    final elevatorExcluded = floor == 0 && rand.nextBool();
    return Apartment(
      id: i + 1,
      area: area.toDouble(),
      floor: floor,
      elevatorExcluded: elevatorExcluded,
    );
  });

  return Building(
    apartments: apartments,
    expense: const Expense(
      fixed: 500,
      extra: 100,
      elevator: 150,
      heating: 300,
    ),
  );
}

