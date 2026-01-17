// lib/state/providers/labour_provider.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/database/models/labor.dart';

class LabourProvider with ChangeNotifier {
  final DBHelper dbHelper;
  List<Labor> _labors = [];
  bool _isLoading = false;
  Labor? _selectedLabor;

  LabourProvider(this.dbHelper);

  List<Labor> get labors => _labors;
  bool get isLoading => _isLoading;
  Labor? get selectedLabor => _selectedLabor;

  Future<void> loadLabors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final laborData = await dbHelper.getAllLabor();
      _labors = laborData.map((map) => Labor.fromMap(map)).toList();
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
          .where((labor) => labor['project_id'] == projectId)
          .map((map) => Labor.fromMap(map))
          .toList();
    } catch (e) {
      print('Error loading labors by project: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLabor(Labor labor) async {
    try {
      await dbHelper.insertLabor(labor.toMap());
      await loadLabors();
    } catch (e) {
      print('Error adding labor: $e');
      rethrow;
    }
  }

  Future<void> updateLabor(Labor labor) async {
    try {
      if (labor.id != null) {
        await dbHelper.updateLabor(labor.id!, labor.toMap());
        await loadLabors();
      }
    } catch (e) {
      print('Error updating labor: $e');
      rethrow;
    }
  }

  Future<void> deleteLabor(int id) async {
    try {
      await dbHelper.deleteLabor(id);
      await loadLabors();
    } catch (e) {
      print('Error deleting labor: $e');
      rethrow;
    }
  }

  void selectLabor(Labor? labor) {
    _selectedLabor = labor;
    notifyListeners();
  }
}