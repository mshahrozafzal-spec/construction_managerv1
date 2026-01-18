// lib/state/providers/labor_provider.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/data/local/db_helper.dart';
import 'package:construction_manager/data/models/labor_model.dart';

class laborProvider with ChangeNotifier {
  final DBHelper dbHelper;
  List<LaborModel> _labors = [];
  bool _isLoading = false;
  LaborModel? _selectedLabor;

  laborProvider(this.dbHelper);

  List<LaborModel> get labors => _labors;
  bool get isLoading => _isLoading;
  LaborModel? get selectedLabor => _selectedLabor;

  Future<void> loadLabors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final laborData = await dbHelper.getAllLabor();
      _labors = laborData.map((map) => LaborModel.fromMap(map)).toList();
    } catch (e) {
      print('Error loading labors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLaborsByProject(int projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final laborData = await dbHelper.getAllLabor();
      _labors = laborData
          .where((LaborModel) => LaborModel['project_id'] == projectId)
          .map((map) => LaborModel.fromMap(map))
          .toList();
    } catch (e) {
      print('Error loading labors by ProjectModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLabor(LaborModel LaborModel) async {
    try {
      await dbHelper.insertLabor(LaborModel.toMap());
      await loadLabors();
    } catch (e) {
      print('Error adding LaborModel: $e');
      rethrow;
    }
  }

  Future<void> updateLabor(LaborModel LaborModel) async {
    try {
      if (LaborModel.id != null) {
        await dbHelper.updateLabor(LaborModel.id!, LaborModel.toMap());
        await loadLabors();
      }
    } catch (e) {
      print('Error updating LaborModel: $e');
      rethrow;
    }
  }

  Future<void> deleteLabor(int id) async {
    try {
      await dbHelper.deleteLabor(id);
      await loadLabors();
    } catch (e) {
      print('Error deleting LaborModel: $e');
      rethrow;
    }
  }

  void selectLabor(LaborModel? LaborModel) {
    _selectedLabor = LaborModel;
    notifyListeners();
  }
}
