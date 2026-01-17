// lib/database/db_provider.dart
import 'db_helper.dart';

class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  factory DBProvider() => _instance;
  DBProvider._internal();

  DBHelper? _dbHelper;

  DBHelper get dbHelper {
    _dbHelper ??= DBHelper();
    return _dbHelper!;
  }

  // Initialize database on app start
  Future<void> initialize() async {
    await dbHelper.database;
  }
}