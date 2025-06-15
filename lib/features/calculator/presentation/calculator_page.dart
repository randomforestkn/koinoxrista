// lib/features/calculator/presentation/calculator_page.dart – refined validation & minor UI polish

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'result_page.dart';


import '../../../models/apartment.dart';
import '../../../models/expense.dart';
import '../../../models/building.dart';
import '../../../services/calculation_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod State
// ─────────────────────────────────────────────────────────────────────────────

class ExpenseState {
  final double fixed;
  final double extra;
  final double elevator;
  final double heating;

  const ExpenseState({
    this.fixed = 0,
    this.extra = 0,
    this.elevator = 0,
    this.heating = 0,
  });

  Expense toExpense() => Expense(
        fixed: fixed,
        extra: extra,
        elevator: elevator,
        heating: heating,
      );

  ExpenseState copyWith({double? fixed, double? extra, double? elevator, double? heating}) =>
      ExpenseState(
        fixed: fixed ?? this.fixed,
        extra: extra ?? this.extra,
        elevator: elevator ?? this.elevator,
        heating: heating ?? this.heating,
      );
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  ExpenseNotifier() : super(const ExpenseState());

  void _update(ExpenseState v) => state = v;
  void updateFixed(String v) => _update(state.copyWith(fixed: _toDouble(v)));
  void updateExtra(String v) => _update(state.copyWith(extra: _toDouble(v)));
  void updateElevator(String v) => _update(state.copyWith(elevator: _toDouble(v)));
  void updateHeating(String v) => _update(state.copyWith(heating: _toDouble(v)));

  double _toDouble(String v) => double.tryParse(v.replaceAll(',', '.')) ?? 0;
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) => ExpenseNotifier());

// Apartments provider
class ApartmentsNotifier extends StateNotifier<List<Apartment>> {
  ApartmentsNotifier() : super([const Apartment(id: 1, area: 0, floor: 0)]);

  void setCount(int count) {
    if (count < 1) return;
    // Trim or extend list preserving existing input
    state = List.generate(count, (i) {
      if (i < state.length) return state[i];
      return Apartment(id: i + 1, area: 0, floor: 0);
    });
  }

  void updateArea(int id, String v) => _replace(id, area: double.tryParse(v.replaceAll(',', '.')) ?? 0);
  void updateFloor(int id, String v) => _replace(id, floor: int.tryParse(v) ?? 0);
  void toggleElevator(int id) => _replace(id, elevatorExcluded: !state.firstWhere((a) => a.id == id).elevatorExcluded);

  void _replace(int id, {double? area, int? floor, bool? elevatorExcluded}) {
    state = [
      for (final a in state)
        if (a.id == id)
          Apartment(
            id: a.id,
            area: area ?? a.area,
            floor: floor ?? a.floor,
            elevatorExcluded: elevatorExcluded ?? a.elevatorExcluded,
            customMill: a.customMill,
          )
        else
          a,
    ];
  }
}

final apartmentsProvider = StateNotifierProvider<ApartmentsNotifier, List<Apartment>>((ref) => ApartmentsNotifier());

// ─────────────────────────────────────────────────────────────────────────────
// UI
// ─────────────────────────────────────────────────────────────────────────────

class CalculatorPage extends ConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apartments = ref.watch(apartmentsProvider);
    final expense = ref.watch(expenseProvider);
    final formKey = GlobalKey<FormState>();
    final countCtrl = TextEditingController(text: apartments.length.toString());

    return Scaffold(
      appBar: AppBar(title: const Text('Υπολογισμός Κοινοχρήστων')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: countCtrl,
              decoration: const InputDecoration(labelText: 'Πλήθος διαμερισμάτων', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (v) => ref.read(apartmentsProvider.notifier).setCount(int.tryParse(v) ?? 1),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1) return 'Δώσε ≥ 1';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _apartmentsList(context, ref, apartments),
            const Divider(height: 32),
            _expensesSection(ref, expense),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('ΥΠΟΛΟΓΙΣΜΟΣ'),
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Συμπληρώστε σωστά όλα τα πεδία.')));
                    return;
                  }
                  final building = Building(apartments: apartments, expense: expense.toExpense());
                  try {
                    final results = CalculationService().calculateShares(building);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultPage(results: results)));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _apartmentsList(BuildContext context, WidgetRef ref, List<Apartment> apartments) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: apartments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final a = apartments[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Text('Δ${a.id}', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: a.area == 0 ? '' : a.area.toStringAsFixed(0),
                  decoration: const InputDecoration(labelText: 'm²', border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => ref.read(apartmentsProvider.notifier).updateArea(a.id, v),
                  validator: (v) {
                    final d = double.tryParse(v?.replaceAll(',', '.') ?? '');
                    if (d == null || d <= 0) return '>'; return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: TextFormField(
                  initialValue: a.floor.toString(),
                  decoration: const InputDecoration(labelText: 'Όροφος', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => ref.read(apartmentsProvider.notifier).updateFloor(a.id, v),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const Text('Εξ. Ανελκ.'),
                  Checkbox(
                    value: a.elevatorExcluded,
                    onChanged: (_) => ref.read(apartmentsProvider.notifier).toggleElevator(a.id),
                  ),
                ],
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _expensesSection(WidgetRef ref, ExpenseState e) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Έξοδα', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700])),
      const SizedBox(height: 8),
      Row(children: [
        _numField('Πάγια €', e.fixed, ref.read(expenseProvider.notifier).updateFixed),
        const SizedBox(width: 8),
        _numField('Έκτακτα €', e.extra, ref.read(expenseProvider.notifier).updateExtra),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        _numField('Ανελκ. €', e.elevator, ref.read(expenseProvider.notifier).updateElevator),
        const SizedBox(width: 8),
        _numField('Θέρμανση €', e.heating, ref.read(expenseProvider.notifier).updateHeating),
      ]),
    ]);
  }

  Widget _numField(String label, double initial, Function(String) onChanged) {
    return Expanded(
      child: TextFormField(
        initialValue: initial == 0 ? '' : initial.toStringAsFixed(0),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        validator: (v) {
          if (v != null && v.isNotEmpty && double.tryParse(v.replaceAll(',', '.')) == null) return 'Ν';
          return null;
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ResultPage stays unchanged from previous version
// ─────────────────────────────────────────────────────────────────────────────
