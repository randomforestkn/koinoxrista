// lib/models/expense.dart
class Expense {
  final double fixed; // Πάγια
  final double extra; // Έκτακτα
  final double elevator; // Ανελκυστήρας
  final double heating; // Θέρμανση

  const Expense({
    required this.fixed,
    required this.extra,
    required this.elevator,
    required this.heating,
  });
}
