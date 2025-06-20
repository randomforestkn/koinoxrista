// lib/services/hive_save_service.dart

import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/building.dart';
import '../models/result_row.dart';

class HiveSaveService {
  static const String _buildingKey = 'last_building';
  static const String _resultsKey = 'last_results';

  final Box box;
  HiveSaveService(this.box);

  Future<void> save(Building building, List<ResultRow> results) async {
    await box.put(_buildingKey, jsonEncode(building.toJson()));
    await box.put(_resultsKey, jsonEncode(results.map((r) => r.toJson()).toList()));
  }

  Building? loadBuilding() {
    final jsonString = box.get(_buildingKey);
    if (jsonString == null) return null;
    return Building.fromJson(jsonDecode(jsonString));
  }

  List<ResultRow>? loadResults() {
    final jsonString = box.get(_resultsKey);
    if (jsonString == null) return null;
    final list = jsonDecode(jsonString) as List;
    return list.map((e) => ResultRow.fromJson(e)).toList();
  }

  void clear() {
    box.delete(_buildingKey);
    box.delete(_resultsKey);
  }
}
