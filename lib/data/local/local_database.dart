// lib/data/local/local_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;

  // Database version - changed from 1 to 8
  static const int _databaseVersion = 8;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'construction_manager.db');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Projects table
    await db.execute('''
      CREATE TABLE projects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        client_name TEXT NOT NULL,
        location TEXT NOT NULL,
        estimated_budget REAL NOT NULL,
        description TEXT,
        start_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        progress INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    // Labour table
    await db.execute('''
      CREATE TABLE labour(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        daily_rate REAL NOT NULL,
        total_days INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    // ============ NEW TABLES FOR MATERIAL MANAGEMENT ============

    // Material Categories table
    await db.execute('''
      CREATE TABLE material_categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        parent_category TEXT,
        icon TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Suppliers table
    await db.execute('''
      CREATE TABLE suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact_person TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        gst_number TEXT,
        payment_terms TEXT,
        credit_limit REAL DEFAULT 0,
        last_order_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Materials table (enhanced)
    await db.execute('''
      CREATE TABLE materials(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT,
        description TEXT,
        category_id INTEGER,
        current_stock REAL DEFAULT 0,
        unit TEXT DEFAULT 'pieces',
        min_stock_level REAL DEFAULT 5,
        max_stock_level REAL DEFAULT 100,
        unit_price REAL DEFAULT 0,
        supplier_id INTEGER,
        specifications TEXT,
        image_url TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES material_categories(id) ON DELETE SET NULL,
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
      )
    ''');

    // Material Price History table
    await db.execute('''
      CREATE TABLE material_prices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material_id INTEGER NOT NULL,
        supplier_id INTEGER,
        price REAL NOT NULL,
        effective_date TEXT NOT NULL,
        expiry_date TEXT,
        is_current INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE,
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
      )
    ''');

    // Insert default material categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Use batch for atomic operations
    final batch = db.batch();

    // Version 2 to 3 upgrades
    if (oldVersion < 3) {
      // Add any columns needed for version 3
    }

    // Version 3 to 4 upgrades
    if (oldVersion < 4) {
      // Add any columns needed for version 4
    }

    // Version 4 to 5 upgrades
    if (oldVersion < 5) {
      // Add any columns needed for version 5
    }

    // Version 5 to 6 upgrades
    if (oldVersion < 6) {
      // Add any columns needed for version 6
    }

    // Version 6 to 7 upgrades
    if (oldVersion < 7) {
      // Add any columns needed for version 7
    }

    // Version 7 to 8 - Material Management
    if (oldVersion < 8) {
      // Create Material Categories table if not exists
      batch.execute('''
        CREATE TABLE IF NOT EXISTS material_categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          parent_category TEXT,
          icon TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      // Create Suppliers table if not exists
      batch.execute('''
        CREATE TABLE IF NOT EXISTS suppliers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          contact_person TEXT,
          phone TEXT,
          email TEXT,
          address TEXT,
          gst_number TEXT,
          payment_terms TEXT,
          credit_limit REAL DEFAULT 0,
          last_order_date TEXT,
          notes TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      // Create enhanced Materials table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS materials(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          code TEXT,
          description TEXT,
          category_id INTEGER,
          current_stock REAL DEFAULT 0,
          unit TEXT DEFAULT 'pieces',
          min_stock_level REAL DEFAULT 5,
          max_stock_level REAL DEFAULT 100,
          unit_price REAL DEFAULT 0,
          supplier_id INTEGER,
          specifications TEXT,
          image_url TEXT,
          notes TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES material_categories(id) ON DELETE SET NULL,
          FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
        )
      ''');

      // Create Material Price History table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS material_prices(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          material_id INTEGER NOT NULL,
          supplier_id INTEGER,
          price REAL NOT NULL,
          effective_date TEXT NOT NULL,
          expiry_date TEXT,
          is_current INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE,
          FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
        )
      ''');
    }

    // Commit all batch operations
    await batch.commit();

    // Insert default categories after version 8 upgrade
    if (oldVersion < 8) {
      await _insertDefaultCategories(db);
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    // Check if categories already exist
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM material_categories');
    final count = Sqflite.firstIntValue(countResult) ?? 0;

    if (count == 0) {
      final defaultCategories = [
        {
          'name': 'Cement & Concrete',
          'icon': '🏗️',
          'description': 'Cement, concrete mix, aggregates',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Steel & Reinforcement',
          'icon': '🔩',
          'description': 'TMT bars, structural steel, mesh',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Bricks & Blocks',
          'icon': '🧱',
          'description': 'Clay bricks, concrete blocks, AAC blocks',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Aggregates',
          'icon': '🪨',
          'description': 'Sand, stone, gravel, ballast',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Electrical',
          'icon': '💡',
          'description': 'Wires, switches, fixtures, panels',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Plumbing',
          'icon': '🚿',
          'description': 'Pipes, fittings, fixtures, valves',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Finishing',
          'icon': '🎨',
          'description': 'Paint, tiles, flooring, hardware',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Safety',
          'icon': '🦺',
          'description': 'PPE, safety equipment, signage',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Formwork & Scaffolding',
          'icon': '🪜',
          'description': 'Shuttering, scaffolding, support systems',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'name': 'Tools & Equipment',
          'icon': '🛠️',
          'description': 'Hand tools, power tools, machinery',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      for (var category in defaultCategories) {
        await db.insert('material_categories', category);
      }
      print('Inserted ${defaultCategories.length} default material categories');
    }
  }

  // ============ MATERIAL MANAGEMENT METHODS ============

  // Material Categories CRUD
  Future<int> insertMaterialCategory(Map<String, dynamic> category) async {
    final db = await database;
    category['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('material_categories', category);
  }

  Future<List<Map<String, dynamic>>> getAllMaterialCategories() async {
    final db = await database;
    return await db.query('material_categories', orderBy: 'name');
  }

  // Suppliers CRUD
  Future<int> insertSupplier(Map<String, dynamic> supplier) async {
    final db = await database;
    supplier['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('suppliers', supplier);
  }

  Future<List<Map<String, dynamic>>> getAllSuppliers() async {
    final db = await database;
    return await db.query('suppliers', orderBy: 'name');
  }

  Future<Map<String, dynamic>?> getSupplierById(int id) async {
    final db = await database;
    final results = await db.query(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Materials CRUD
  Future<int> insertMaterial(Map<String, dynamic> material) async {
    final db = await database;
    material['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('materials', material);
  }

  Future<List<Map<String, dynamic>>> getAllMaterials() async {
    final db = await database;
    return await db.query('materials', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getMaterialsByCategory(int categoryId) async {
    final db = await database;
    return await db.query(
      'materials',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name',
    );
  }

  Future<List<Map<String, dynamic>>> getLowStockMaterials() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM materials 
      WHERE current_stock <= min_stock_level 
      ORDER BY current_stock ASC
    ''');
  }

  Future<Map<String, dynamic>?> getMaterialById(int id) async {
    final db = await database;
    final results = await db.query(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateMaterial(int id, Map<String, dynamic> material) async {
    final db = await database;
    return await db.update(
      'materials',
      material,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMaterial(int id) async {
    final db = await database;
    return await db.delete(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Material Price History
  Future<int> insertMaterialPrice(Map<String, dynamic> price) async {
    final db = await database;
    price['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('material_prices', price);
  }

  Future<List<Map<String, dynamic>>> getMaterialPriceHistory(int materialId) async {
    final db = await database;
    return await db.query(
      'material_prices',
      where: 'material_id = ?',
      whereArgs: [materialId],
      orderBy: 'effective_date DESC',
    );
  }

  // Search functionality
  Future<List<Map<String, dynamic>>> searchMaterials(String query) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM materials 
      WHERE name LIKE ? OR code LIKE ? OR description LIKE ?
      ORDER BY name
    ''', ['%$query%', '%$query%', '%$query%']);
  }

  // Cost Control Analytics
  Future<double> getTotalInventoryValue() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(current_stock * unit_price) as total_value 
      FROM materials 
      WHERE unit_price > 0
    ''');
    return result.first['total_value'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getCategoryWiseInventoryValue() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        c.name as category,
        SUM(m.current_stock * m.unit_price) as total_value
      FROM materials m
      LEFT JOIN material_categories c ON m.category_id = c.id
      WHERE m.unit_price > 0
      GROUP BY c.name
      ORDER BY total_value DESC
    ''');

    final Map<String, double> categoryValues = {};
    for (var row in result) {
      final category = row['category'] as String? ?? 'Uncategorized';
      final value = (row['total_value'] as num?)?.toDouble() ?? 0;
      categoryValues[category] = value;
    }
    return categoryValues;
  }

  // Stock alerts
  Future<Map<String, dynamic>> getMaterialStats() async {
    final db = await database;

    final totalMaterials = await db.rawQuery('SELECT COUNT(*) as count FROM materials');
    final lowStockCount = await db.rawQuery('''
      SELECT COUNT(*) as count FROM materials 
      WHERE current_stock <= min_stock_level
    ''');
    final outOfStockCount = await db.rawQuery('''
      SELECT COUNT(*) as count FROM materials 
      WHERE current_stock <= 0
    ''');
    final totalValue = await getTotalInventoryValue();

    return {
      'total_materials': Sqflite.firstIntValue(totalMaterials) ?? 0,
      'low_stock': Sqflite.firstIntValue(lowStockCount) ?? 0,
      'out_of_stock': Sqflite.firstIntValue(outOfStockCount) ?? 0,
      'total_value': totalValue,
    };
  }

  // ============ EXISTING METHODS (keep these) ============

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Project methods
  Future<int> insertProject(Map<String, dynamic> project) async {
    final db = await database;
    project['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('projects', project);
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await database;
    return await db.query('projects', orderBy: 'created_at DESC');
  }

  // Task methods
  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    task['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'created_at DESC');
  }

  // Labour methods
  Future<int> insertLabour(Map<String, dynamic> labour) async {
    final db = await database;
    return await db.insert('labour', labour);
  }

  Future<List<Map<String, dynamic>>> getLabour() async {
    final db = await database;
    return await db.query('labour', orderBy: 'id DESC');
  }

  // Expense methods
  Future<int> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    expense['date'] = DateTime.now().toIso8601String();
    return await db.insert('expenses', expense);
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return await db.query('expenses', orderBy: 'date DESC');
  }
}