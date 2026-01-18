import 'package:construction_manager/data/local/db_helper.dart';
import 'package:construction_manager/data/models/material_model.dart';
import 'package:construction_manager/data/models/material_category_model.dart';
import 'package:construction_manager/data/models/supplier_model.dart';

class MaterialRepository {
  final DBHelper _database;

  MaterialRepository({DBHelper? database})
      : _database = database ?? DBHelper();

  // ============ MATERIAL CRUD ============
  Future<int> addMaterial(MaterialModel material) async {
    final materialMap = material.toMap();
    materialMap['created_at'] = DateTime.now().toIso8601String();
    return await _database.insertMaterial(materialMap);
  }

  Future<List<MaterialModel>> getAllMaterials() async {
    final maps = await _database.getAllMaterials();
    return maps.map((map) => MaterialModel.fromMap(map)).toList();
  }

  Future<MaterialModel?> getMaterialById(int id) async {
    final map = await _database.getMaterialById(id);
    return map != null ? MaterialModel.fromMap(map) : null;
  }

  Future<int> updateMaterial(MaterialModel material) async {
    if (material.id == null) throw Exception('Material ID is required for update');
    return await _database.updateMaterial(material.id!, material.toMap());
  }

  Future<int> deleteMaterial(int id) async {
    return await _database.deleteMaterial(id);
  }

  Future<List<MaterialModel>> getMaterialsByCategory(int categoryId) async {
    final maps = await _database.getMaterialsByCategory(categoryId);
    return maps.map((map) => MaterialModel.fromMap(map)).toList();
  }

  Future<List<MaterialModel>> getLowStockMaterials() async {
    final maps = await _database.getLowStockMaterials();
    return maps.map((map) => MaterialModel.fromMap(map)).toList();
  }

  // ============ CATEGORY CRUD ============
  Future<int> addCategory(MaterialCategoryModel category) async {
    final categoryMap = category.toMap();
    categoryMap['created_at'] = DateTime.now().toIso8601String();
    return await _database.insertMaterialCategory(categoryMap);
  }

  Future<List<MaterialCategoryModel>> getAllCategories() async {
    final maps = await _database.getAllMaterialCategories();
    return maps.map((map) => MaterialCategoryModel.fromMap(map)).toList();
  }

  // ============ SUPPLIER CRUD ============
  Future<int> addSupplier(SupplierModel supplier) async {
    final supplierMap = supplier.toMap();
    supplierMap['created_at'] = DateTime.now().toIso8601String();
    return await _database.insertSupplier(supplierMap);
  }

  Future<List<SupplierModel>> getAllSuppliers() async {
    final maps = await _database.getAllSuppliers();
    return maps.map((map) => SupplierModel.fromMap(map)).toList();
  }

  Future<SupplierModel?> getSupplierById(int id) async {
    final map = await _database.getSupplierById(id);
    return map != null ? SupplierModel.fromMap(map) : null;
  }

  // ============ COST CONTROL & ANALYTICS ============
  Future<double> getTotalInventoryValue() async {
    final materials = await getAllMaterials();
    double total = 0.0;
    for (var material in materials) {
      total += material.totalValue;
    }
    return total;
  }

  Future<Map<String, double>> getCategoryWiseInventoryValue() async {
    final materials = await getAllMaterials();
    final categories = await getAllCategories();

    Map<String, double> result = {};

    for (var category in categories) {
      final categoryMaterials = materials.where((m) => m.categoryId == category.id);
      final totalValue = categoryMaterials.fold(0.0, (sum, m) => sum + m.totalValue);
      if (totalValue > 0) {
        result[category.name] = totalValue;
      }
    }

    // Handle materials without category
    final uncategorizedMaterials = materials.where((m) => m.categoryId == null);
    final uncategorizedValue = uncategorizedMaterials.fold(0.0, (sum, m) => sum + m.totalValue);
    if (uncategorizedValue > 0) {
      result['Uncategorized'] = uncategorizedValue;
    }

    return result;
  }

  Future<Map<String, dynamic>> getMaterialStats() async {
    final materials = await getAllMaterials();

    return {
      'total_materials': materials.length,
      'low_stock': materials.where((m) => m.isLowStock).length,
      'out_of_stock': materials.where((m) => m.currentStock <= 0).length,
    };
  }

  Future<List<Map<String, dynamic>>> generateInventoryReport() async {
    final materials = await getAllMaterials();
    final categories = await getAllCategories();

    return materials.map((material) {
      final category = material.categoryId != null
          ? categories.firstWhere((c) => c.id == material.categoryId, orElse: () => MaterialCategoryModel(name: 'Uncategorized', createdAt: DateTime.now()))
          : MaterialCategoryModel(name: 'Uncategorized', createdAt: DateTime.now());

      return {
        'id': material.id,
        'name': material.name,
        'code': material.code ?? 'N/A',
        'category': category.name,
        'stock': material.currentStock,
        'unit': material.unit,
        'unit_price': material.unitPrice ?? 0.0,
        'total_value': material.totalValue,
        'is_low_stock': material.isLowStock,
      };
    }).toList();
  }

  Future<List<MaterialModel>> searchMaterials(String query) async {
    final maps = await _database.searchMaterials(query);
    return maps.map((map) => MaterialModel.fromMap(map)).toList();
  }

  // ============ PRICE HISTORY ============
  Future<int> addMaterialPrice(Map<String, dynamic> price) async {
    price['created_at'] = DateTime.now().toIso8601String();
    return await _database.insertMaterialPrice(price);
  }

  Future<List<Map<String, dynamic>>> getMaterialPriceHistory(int materialId) async {
    return await _database.getMaterialPriceHistory(materialId);
  }

  // ============ BULK OPERATIONS ============
  Future<void> updateMaterialStock(int materialId, double newStock) async {
    final material = await getMaterialById(materialId);
    if (material != null) {
      final updatedMaterial = material.copyWith(currentStock: newStock);
      await updateMaterial(updatedMaterial);
    }
  }

  Future<void> adjustMaterialStock(int materialId, double adjustment) async {
    final material = await getMaterialById(materialId);
    if (material != null) {
      final newStock = material.currentStock + adjustment;
      final updatedMaterial = material.copyWith(currentStock: newStock);
      await updateMaterial(updatedMaterial);
    }
  }
}