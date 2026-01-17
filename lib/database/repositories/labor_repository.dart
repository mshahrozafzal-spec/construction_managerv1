// lib/database/repositories/labor_repository.dart
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/database/models/labor.dart';

class LaborRepository {
  final DBHelper dbHelper;

  LaborRepository({DBHelper? dbHelper}) : dbHelper = dbHelper ?? DBHelper();

  Future<int> addLabor(Labor labor) async {
    return await dbHelper.insertLabor(labor.toMap());
  }

  Future<List<Labor>> getAllLabors() async {
    final labors = await dbHelper.getAllLabor();
    return labors.map((map) => Labor.fromMap(map)).toList();
  }

  Future<List<Labor>> getLaborsByProject(int projectId) async {
    final labors = await dbHelper.getAllLabor();
    return labors
        .where((map) => map['project_id'] == projectId)
        .map((map) => Labor.fromMap(map))
        .toList();
  }

  Future<int> updateLabor(Labor labor) async {
    if (labor.id == null) return 0;
    return await dbHelper.updateLabor(labor.id!, labor.toMap());
  }

  Future<int> deleteLabor(int id) async {
    return await dbHelper.deleteLabor(id);
  }
}