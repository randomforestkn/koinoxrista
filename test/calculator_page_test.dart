import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koinoxrista/features/calculator/presentation/calculator_page.dart';
import 'package:koinoxrista/features/calculator/presentation/result_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CalculatorPage widget tests', () {
    testWidgets('shows validation error when area is empty', (tester) async {
      // Increase surface to avoid overflow on ResultPage during test run
      await tester.binding.setSurfaceSize(const Size(1080, 1920));

      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: CalculatorPage())));
      await tester.pumpAndSettle();

      // Πατάμε το κουμπί υπολογισμού χωρίς δεδομένα
      await tester.tap(find.text('ΥΠΟΛΟΓΙΣΜΟΣ'));
      await tester.pump();

      // SnackBar με μήνυμα σφάλματος
      expect(find.textContaining('Συμπληρώστε'), findsOneWidget);
    });

    testWidgets('navigates to ResultPage on valid input', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));

      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: CalculatorPage())));
      await tester.pumpAndSettle();

      // Συμπληρώνουμε τη στήλη m² με 100
      await tester.enterText(find.widgetWithText(TextFormField, 'm²').first, '100');
      await tester.pump();

      // Πατάμε ΥΠΟΛΟΓΙΣΜΟΣ
      await tester.tap(find.text('ΥΠΟΛΟΓΙΣΜΟΣ'));
      await tester.pumpAndSettle();

      // Οθόνη αποτελεσμάτων εμφανίζεται
      expect(find.byType(ResultPage), findsOneWidget);
    });
  });
}
