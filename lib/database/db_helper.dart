// lib/database/db_helper.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'construction_manager.db');
    return await openDatabase(
      path,
      version: 7, // INCREASED FROM 6 TO 7
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Add this init method
  Future<void> init() async {
    await database; // This will initialize the database
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create projects table with ALL columns
    await db.execute('''
      CREATE TABLE projects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        client_name TEXT,
        contact_person TEXT,
        client_phone TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT,
        budget REAL DEFAULT 0.0,
        spent REAL DEFAULT 0.0,
        progress REAL DEFAULT 0.0,
        status TEXT DEFAULT 'Planning',
        location TEXT,
        address TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Create tasks table with ALL columns
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT DEFAULT 'task',
        priority TEXT DEFAULT 'Medium',
        status TEXT DEFAULT 'pending',
        start_date TEXT NOT NULL,
        end_date TEXT,
        estimated_hours REAL DEFAULT 0,
        actual_hours REAL DEFAULT 0,
        assigned_to TEXT,
        notes TEXT,
        completed_date TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    // Create labor table with ALL columns
    await db.execute('''
      CREATE TABLE labor(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        role TEXT,
        status TEXT DEFAULT 'Active',
        rate_per_hour REAL DEFAULT 0,
        monthly_wage REAL DEFAULT 0,
        daily_wage REAL DEFAULT 0,
        total_advance REAL DEFAULT 0,
        address TEXT,
        project_id INTEGER,
        id_number TEXT,
        skills TEXT,
        emergency_contact TEXT,
        notes TEXT,
        join_date TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL
      )
    ''');

    // Create holidays table
    await db.execute('''
      CREATE TABLE holidays(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT DEFAULT 'general',
        recurring INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Create materials table
    await db.execute('''
      CREATE TABLE materials(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT,
        quantity REAL DEFAULT 0,
        unit TEXT DEFAULT 'pieces',
        unit_price REAL DEFAULT 0,
        supplier TEXT,
        project_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL
      )
    ''');

    // Create expenses table WITH NOTES COLUMN - REMOVED COMMENT
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER,
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        receipt_image TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    // Create work_log table for time tracking
    await db.execute('''
      CREATE TABLE work_log(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER,
        labor_id INTEGER,
        date TEXT NOT NULL,
        hours REAL NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
        FOREIGN KEY (labor_id) REFERENCES labor(id) ON DELETE SET NULL
      )
    ''');

    // Create attendance table
    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        labor_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        hours REAL DEFAULT 8.0,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (labor_id) REFERENCES labor(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN estimated_hours REAL DEFAULT 0');
      await db.execute('ALTER TABLE tasks ADD COLUMN actual_hours REAL DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS holidays(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          date TEXT NOT NULL,
          type TEXT DEFAULT 'general',
          recurring INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE labor ADD COLUMN project_id INTEGER');
      await db.execute('ALTER TABLE labor ADD COLUMN address TEXT');
    }
    if (oldVersion < 5) {
      // Add missing columns to projects table
      await db.execute('ALTER TABLE projects ADD COLUMN location TEXT');
      await db.execute('ALTER TABLE projects ADD COLUMN notes TEXT');
      await db.execute('ALTER TABLE projects ADD COLUMN contact_person TEXT');
      await db.execute('ALTER TABLE projects ADD COLUMN spent REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE projects ADD COLUMN progress REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE projects ADD COLUMN address TEXT');

      // Add missing columns to tasks table
      await db.execute('ALTER TABLE tasks ADD COLUMN type TEXT DEFAULT "task"');
      await db.execute('ALTER TABLE tasks ADD COLUMN notes TEXT');

      // Add missing columns to labor table
      await db.execute('ALTER TABLE labor ADD COLUMN status TEXT DEFAULT "Active"');
      await db.execute('ALTER TABLE labor ADD COLUMN id_number TEXT');
      await db.execute('ALTER TABLE labor ADD COLUMN skills TEXT');
      await db.execute('ALTER TABLE labor ADD COLUMN emergency_contact TEXT');
      await db.execute('ALTER TABLE labor ADD COLUMN notes TEXT');
      await db.execute('ALTER TABLE labor ADD COLUMN join_date TEXT');
      await db.execute('ALTER TABLE labor ADD COLUMN monthly_wage REAL DEFAULT 0');
      await db.execute('ALTER TABLE labor ADD COLUMN daily_wage REAL DEFAULT 0');
      await db.execute('ALTER TABLE labor ADD COLUMN total_advance REAL DEFAULT 0');
    }
    if (oldVersion < 6) {
      // Create attendance table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS attendance(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          labor_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          status TEXT NOT NULL,
          hours REAL DEFAULT 8.0,
          notes TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (labor_id) REFERENCES labor(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 7) {
      // Add notes column to expenses table
      await db.execute('ALTER TABLE expenses ADD COLUMN notes TEXT');
    }
  }

  // ============ PROJECT METHODS ============
  Future<int> insertProject(Map<String, dynamic> project) async {
    final db = await database;
    project['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('projects', project);
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await database;
    return await db.query('projects', orderBy: 'created_at DESC');
  }

  Future<int> updateProject(int id, Map<String, dynamic> project) async {
    final db = await database;
    project['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('projects', project, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // ============ TASK METHODS ============
  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    task['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getTasksByProject(int projectId) async {
    final db = await database;
    return await db.query('tasks',
        where: 'project_id = ?',
        whereArgs: [projectId],
        orderBy: 'status, priority DESC, end_date'
    );
  }

  Future<int> updateTask(int id, Map<String, dynamic> task) async {
    final db = await database;
    return await db.update('tasks', task, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ============ LABOR METHODS ============
  Future<int> insertLabor(Map<String, dynamic> labor) async {
    final db = await database;
    labor['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('labor', labor);
  }

  Future<List<Map<String, dynamic>>> getAllLabor() async {
    final db = await database;
    return await db.query('labor', orderBy: 'created_at DESC');
  }

  Future<int> updateLabor(int id, Map<String, dynamic> labor) async {
    final db = await database;
    return await db.update('labor', labor, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteLabor(int id) async {
    final db = await database;
    return await db.delete('labor', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getLaborsByProject(int projectId) async {
    final db = await database;
    return await db.query('labor',
        where: 'project_id = ?',
        whereArgs: [projectId],
        orderBy: 'created_at DESC'
    );
  }

  // ============ HOLIDAY METHODS ============
  Future<int> insertHoliday(Map<String, dynamic> holiday) async {
    final db = await database;
    holiday['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('holidays', holiday);
  }

  Future<List<Map<String, dynamic>>> getHolidays() async {
    final db = await database;
    return await db.query('holidays', orderBy: 'date');
  }

  Future<int> updateHoliday(int id, Map<String, dynamic> holiday) async {
    final db = await database;
    return await db.update('holidays', holiday, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteHoliday(int id) async {
    final db = await database;
    return await db.delete('holidays', where: 'id = ?', whereArgs: [id]);
  }

  // ============ EXPENSE METHODS ============
  Future<int> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    expense['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('expenses', expense);
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final db = await database;
    return await db.query('expenses', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getExpensesByProject(int projectId) async {
    final db = await database;
    return await db.query('expenses',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'date DESC',
    );
  }

  Future<int> updateExpense(int id, Map<String, dynamic> expense) async {
    final db = await database;
    return await db.update('expenses', expense, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ============ ATTENDANCE METHODS ============
  Future<int> insertAttendance(Map<String, dynamic> attendance) async {
    final db = await database;
    attendance['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('attendance', attendance);
  }

  Future<List<Map<String, dynamic>>> getAttendanceByLabor(int laborId) async {
    final db = await database;
    return await db.query(
      'attendance',
      where: 'labor_id = ?',
      whereArgs: [laborId],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    return await db.query(
      'attendance',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
    );
  }

  Future<int> updateAttendance(int id, Map<String, dynamic> attendance) async {
    final db = await database;
    return await db.update(
      'attendance',
      attendance,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await database;
    return await db.delete(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ DASHBOARD METHODS ============
  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;

    final activeProjects = await db.rawQuery(
        'SELECT COUNT(*) as count FROM projects WHERE status = "active" OR status = "Active" OR status = "Planning"'
    );

    final totalProjects = await db.rawQuery(
        'SELECT COUNT(*) as count FROM projects'
    );

    final pendingTasks = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE status = "pending" OR status = "in_progress"'
    );

    final completedTasks = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE status = "completed"'
    );

    final totalLabor = await db.rawQuery(
        'SELECT COUNT(*) as count FROM labor'
    );

    final upcomingQuery = await db.rawQuery('''
      SELECT COUNT(*) as count FROM tasks 
      WHERE end_date BETWEEN date('now') AND date('now', '+7 days')
      AND status != 'completed'
    ''');

    return {
      'activeProjects': activeProjects.first['count'] ?? 0,
      'totalProjects': totalProjects.first['count'] ?? 0,
      'pendingTasks': pendingTasks.first['count'] ?? 0,
      'completedTasks': completedTasks.first['count'] ?? 0,
      'totalLabor': totalLabor.first['count'] ?? 0,
      'upcomingDeadlines': upcomingQuery.first['count'] ?? 0,
    };
  }

  // ============ UTILITY METHODS ============
  Future<List<Map<String, dynamic>>> getHolidaysBetween(String startDate, String endDate) async {
    final db = await database;
    return await db.query('holidays',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
  }

  Future<int> calculateWorkingDays(DateTime start, DateTime end, {bool excludeWeekends = true}) async {
    final db = await database;

    final holidays = await getHolidaysBetween(
      start.toIso8601String(),
      end.toIso8601String(),
    );

    int workingDays = 0;
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (excludeWeekends && (current.weekday == DateTime.saturday || current.weekday == DateTime.sunday)) {
        current = current.add(const Duration(days: 1));
        continue;
      }

      final isHoliday = holidays.any((holiday) {
        final holidayDate = DateTime.parse(holiday['date'] as String);
        return holidayDate.year == current.year &&
            holidayDate.month == current.month &&
            holidayDate.day == current.day;
      });

      if (!isHoliday) {
        workingDays++;
      }

      current = current.add(const Duration(days: 1));
    }

    return workingDays;
  }
}