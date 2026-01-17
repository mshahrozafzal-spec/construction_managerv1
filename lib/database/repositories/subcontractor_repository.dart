import 'package:sqflite/sqflite.dart';
import 'package:construction_manager/database/db_helper.dart';

class SubcontractorRepository {
  final DBHelper dbHelper;
  SubcontractorRepository(this.dbHelper);

  Future<void> addSubcontractor(Map<String, dynamic> subcontractor) async {
    final db = await dbHelper.database;
    await db.insert('subcontractors', subcontractor);
  }

  Future<List<Map<String, dynamic>>> getAllSubcontractors() async {
    final db = await dbHelper.database;
    return await db.query('subcontractors');
  }

  Future<List<Map<String, dynamic>>> getSubcontractorsByProject(int projectId) async {
    final db = await dbHelper.database;
    return await db.query(
      'subcontractors',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  Future<Map<String, dynamic>?> getSubcontractorById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subcontractors',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> updateSubcontractor(int id, Map<String, dynamic> subcontractor) async {
    final db = await dbHelper.database;
    await db.update(
      'subcontractors',
      subcontractor,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSubcontractor(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'subcontractors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getSubcontractorsByType(String type) async {
    final db = await dbHelper.database;
    return await db.query(
      'subcontractors',
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  // Add these methods to the existing SubcontractorRepository class

  Future<List<Map<String, dynamic>>> getSubcontractorSummary(int projectId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT type, COUNT(*) as count, SUM(total_cost) as total 
      FROM subcontractors 
      WHERE project_id = ?
      GROUP BY type
    ''', [projectId]);
  }

  Future<double> getTotalSubcontractorExpenses(int projectId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(total_cost) as total 
      FROM subcontractors 
      WHERE project_id = ?
    ''', [projectId]);
    return result.first['total'] as double? ?? 0.0;
  }
  Future<double> getTotalSubcontractorCostByProject(int projectId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(total_cost) as total 
      FROM subcontractors 
      WHERE project_id = ?
    ''', [projectId]);
    return result.first['total'] as double? ?? 0.0;
  }
}