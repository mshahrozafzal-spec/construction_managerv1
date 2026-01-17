// lib/database/repositories/attendance_repository.dart
import 'package:construction_manager/database/db_helper.dart';

class AttendanceRepository {
  final DBHelper dbHelper;

  AttendanceRepository({DBHelper? dbHelper}) : dbHelper = dbHelper ?? DBHelper();

  Future<void> addAttendance(Map<String, dynamic> attendance) async {
    final db = await dbHelper.database;
    await db.insert('attendance', attendance);
  }

  Future<List<Map<String, dynamic>>> getAttendanceByLabor(int laborId) async {
    final db = await dbHelper.database;
    return await db.query(
      'attendance',
      where: 'labor_id = ?',
      whereArgs: [laborId],
      orderBy: 'date DESC',
    );
  }

  Future<double> calculateMonthlyWage(int laborId, int year, int month) async {
    final attendance = await getPresentDaysForMonth(laborId, year, month);
    final presentDays = attendance.length;

    final db = await dbHelper.database;
    final laborResult = await db.rawQuery('''
      SELECT daily_wage 
      FROM labors 
      WHERE id = ?
    ''', [laborId]);

    if (laborResult.isEmpty) return 0.0;

    final dailyWage = laborResult.first['daily_wage'] as double? ?? 0.0;
    return presentDays * dailyWage;
  }

  Future<List<Map<String, dynamic>>> getPresentDaysForMonth(int laborId, int year, int month) async {
    final db = await dbHelper.database;
    final monthStr = month.toString().padLeft(2, '0');
    return await db.rawQuery('''
      SELECT * FROM attendance 
      WHERE labor_id = ? 
      AND strftime('%Y-%m', date) = ?
      AND status = 'Present'
    ''', [laborId, '$year-$monthStr']);
  }

  Future<List<Map<String, dynamic>>> getAttendanceForDateRange(
      int laborId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT * FROM attendance 
      WHERE labor_id = ? 
      AND date BETWEEN ? AND ?
      ORDER BY date
    ''', [laborId, startDate.toIso8601String(), endDate.toIso8601String()]);
  }

  Future<List<Map<String, dynamic>>> getAttendanceByDate(DateTime date) async {
    final db = await dbHelper.database;
    final dateStr = date.toIso8601String().split('T')[0];
    return await db.query(
      'attendance',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
    );
  }

  Future<void> updateAttendance(int id, Map<String, dynamic> attendance) async {
    final db = await dbHelper.database;
    await db.update(
      'attendance',
      attendance,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAttendance(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceByProject(int projectId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT a.*, l.name as labor_name 
      FROM attendance a
      JOIN labors l ON a.labor_id = l.id
      WHERE l.project_id = ?
      ORDER BY a.date DESC
    ''', [projectId]);
  }
}