// lib/models/building.dart

import 'apartment.dart';
import 'expense.dart';


class Building {
  final List<Apartment> apartments;
  final Expense expense;

  const Building({required this.apartments, required this.expense});
}
