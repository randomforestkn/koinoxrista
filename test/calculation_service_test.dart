import 'package:flutter_test/flutter_test.dart';

import '../lib/models/apartment.dart';
import '../lib/models/expense.dart';
import '../lib/models/building.dart';
import '../lib/services/calculation_service.dart';

void main() {
  group('CalculationService', () {
    final service = CalculationService();

    // ────────────────────────────────────────────────────────────────────────────
    // Happy‑path & core scenarios
    // ────────────────────────────────────────────────────────────────────────────

    test('happy path distributes total expenses', () {
      final building = Building(
        apartments: [
          const Apartment(id: 1, area: 100, floor: 2),
          const Apartment(id: 2, area: 80, floor: 1),
          const Apartment(id: 3, area: 60, floor: 0, elevatorExcluded: true),
        ],
        expense:
            const Expense(fixed: 120, extra: 60, elevator: 40, heating: 80),
      );

      final results = service.calculateShares(building);
      final totalDistributed =
          results.fold<double>(0, (s, r) => s + r.total);

      expect(totalDistributed, closeTo(300, 0.0001));
    });

    test('apartment excluded from elevator pays zero elevator share', () {
      final building = Building(
        apartments: [
          const Apartment(id: 1, area: 50, floor: 0, elevatorExcluded: true),
          const Apartment(id: 2, area: 50, floor: 1),
        ],
        expense: const Expense(fixed: 0, extra: 0, elevator: 20, heating: 0),
      );

      final results = service.calculateShares(building);
      final apt1 = results.firstWhere((r) => r.apartment.id == 1);
      final apt2 = results.firstWhere((r) => r.apartment.id == 2);

      expect(apt1.shareElevator, 0);
      expect(apt2.shareElevator, closeTo(20, 0.0001));
    });

    test('custom mills override automatic calculation', () {
      final building = Building(
        apartments: [
          const Apartment(id: 1, area: 100, floor: 1, customMill: 0.7),
          const Apartment(id: 2, area: 100, floor: 2),
        ],
        expense: const Expense(fixed: 100, extra: 0, elevator: 0, heating: 0),
      );

      final results = service.calculateShares(building);
      final apt1 = results.firstWhere((r) => r.apartment.id == 1);
      final apt2 = results.firstWhere((r) => r.apartment.id == 2);

      expect(apt1.mills, closeTo(0.7, 0.0001));
      expect(apt2.mills, closeTo(0.3, 0.0001));
      expect(apt1.shareFixed, closeTo(70, 0.0001));
      expect(apt2.shareFixed, closeTo(30, 0.0001));
    });

    // ────────────────────────────────────────────────────────────────────────────
    // Edge‑case scenarios (validation & corner cases)
    // ────────────────────────────────────────────────────────────────────────────

    test('throws if sum of custom mills exceeds 100%', () {
      final building = Building(
        apartments: [
          const Apartment(id: 1, area: 100, floor: 1, customMill: 0.6),
          const Apartment(id: 2, area: 100, floor: 2, customMill: 0.55), // sum 1.15
        ],
        expense: const Expense(fixed: 50, extra: 0, elevator: 0, heating: 0),
      );

      expect(() => service.calculateShares(building), throwsArgumentError);
    });

    test('throws if any expense is negative', () {
      final building = Building(
        apartments: [const Apartment(id: 1, area: 80, floor: 1)],
        expense: const Expense(fixed: -10, extra: 0, elevator: 0, heating: 0),
      );

      expect(() => service.calculateShares(building), throwsArgumentError);
    });

    test('all apartments elevatorExcluded results in zero elevator share', () {
      final building = Building(
        apartments: [
          const Apartment(id: 1, area: 40, floor: 0, elevatorExcluded: true),
          const Apartment(id: 2, area: 60, floor: 1, elevatorExcluded: true),
        ],
        expense: const Expense(fixed: 0, extra: 0, elevator: 100, heating: 0),
      );

      final results = service.calculateShares(building);
      for (final r in results) {
        expect(r.shareElevator, 0);
      }
    });

    test('handles scenario where every apartment has custom mills summing to 100%', () {
      final building = Building(
        apartments: [
          const Apartment(id: 1, area: 70, floor: 1, customMill: 0.2),
          const Apartment(id: 2, area: 90, floor: 2, customMill: 0.3),
          const Apartment(id: 3, area: 140, floor: 3, customMill: 0.5),
        ],
        expense: const Expense(fixed: 100, extra: 50, elevator: 0, heating: 0),
      );

      final results = service.calculateShares(building);
      expect(results.firstWhere((r) => r.apartment.id == 1).mills,
          closeTo(0.2, 0.0001));
      expect(results.firstWhere((r) => r.apartment.id == 2).mills,
          closeTo(0.3, 0.0001));
      expect(results.firstWhere((r) => r.apartment.id == 3).mills,
          closeTo(0.5, 0.0001));
    });
  });
}
