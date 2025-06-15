import 'package:flutter_test/flutter_test.dart';

import '../lib/models/apartment.dart';
import '../lib/models/expense.dart';
import '../lib/models/building.dart';
import '../lib/services/calculation_service.dart';

void main() {
  group('CalculationService', () {
    final service = CalculationService();

    test('happy path distributes total expenses', () {
      // Arrange
      final building = Building(
        apartments: [
          const Apartment(id: 1, area: 100, floor: 2),
          const Apartment(id: 2, area: 80, floor: 1),
          const Apartment(id: 3, area: 60, floor: 0, elevatorExcluded: true),
        ],
        expense: const Expense(fixed: 120, extra: 60, elevator: 40, heating: 80),
      );

      // Act
      final results = service.calculateShares(building);
      final totalDistributed =
          results.fold<double>(0, (s, r) => s + r.total);

      // Assert (allow small floating‑point tolerance)
      expect(totalDistributed,
          closeTo(120 + 60 + 40 + 80, 0.0001));
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

      // custom mills defined
      expect(apt1.mills, closeTo(0.7, 0.0001));
      // remaining mills should be 0.3
      expect(apt2.mills, closeTo(0.3, 0.0001));

      // shares reflect custom mills
      expect(apt1.shareFixed, closeTo(70, 0.0001));
      expect(apt2.shareFixed, closeTo(30, 0.0001));
    });
  });
}
