// lib/models/apartment.dart
class Apartment {
  final int id; // unique identifier 1..N
  final double area; // m²
  final int floor; // 0 = ισόγειο, 1 = Α', ...
  final bool elevatorExcluded; // true αν εξαιρείται από ανελκυστήρα
  final double? customMill; // custom χιλιοστά (0..1) optional

  const Apartment({
    required this.id,
    required this.area,
    required this.floor,
    this.elevatorExcluded = false,
    this.customMill,
  });
}








