// lib/data/repositories/material_repository.dart
import 'package:construction_manager/data/local/local_database.dart';
import 'package:construction_manager/data/models/material_model.dart';
import 'package:construction_manager/data/models/material_category_model.dart';
import 'package:construction_manager/data/models/supplier_model.dart';

class MaterialRepository {
  final LocalDatabase _database;

  MaterialRepository({LocalDatabase? database})
      : _database = database ?? LocalDatabase();

  // ============ MATERIAL CRUD ============
  Future<int> addMaterial(Material material) async {
    return await _database.insertMaterial(material.toMap());
  }

  Future<List<Material>> getAllMaterials() async {
    final maps = await _database.getAllMaterials();
    return maps.map((map) => Material.fromMap(map)).toList();
  }

  Future<Material?> getMaterialById(int id) async {
    final map = await _database.getMaterialById(id);
    return map != null ? Material.fromMap(map) : null;
  }

  Future<int> updateMaterial(Material material) async {
    if (material.id == null) throw Exception('Material ID is required for update');
    return await _database.updateMaterial(material.id!, material.toMap());
  }

  Future<int> deleteMaterial(int id) async {
    return await _database.deleteMaterial(id);
  }

  Future<List<Material>> getMaterialsByCategory(int categoryId) async {
    final maps = await _database.getMaterialsByCategory(categoryId);
    return maps.map((map) => Material.fromMap(map)).toList();
  }

  Future<List<Material>> getLowStockMaterials() async {
    final maps = await _database.getLowStockMaterials();
    return maps.map((map) => Material.fromMap(map)).toList();
  }

  // ============ CATEGORY CRUD ============
  Future<int> addCategory(MaterialCategory category) async {
    return await _database.insertMaterialCategory(category.toMap());
  }

  Future<List<MaterialCategory>> getAllCategories() async {
    final maps = await _database.getAllMaterialCategories();
    return maps.map((map) => MaterialCategory.fromMap(map)).toList();
  }

  // ============ SUPPLIER CRUD ============
  Future<int> addSupplier(Supplier supplier) async {
    return await _database.insertSupplier(supplier.toMap());
  }

  Future<List<Supplier>> getAllSuppliers() async {
    final maps = await _database.getAllSuppliers();
    return maps.map((map) => Supplier.fromMap(map)).toList();
  }

  Future<Supplier?> getSupplierById(int id) async {
    final map = await _database.getSupplierById(id);
    return map != null ? Supplier.fromMap(map) : null;
  }

  // ============ COST CONTROL & ANALYTICS ============
  Future<double> getTotalInventoryValue() async {
    return await _database.getTotalInventoryValue();
  }

  Future<List<Material>> searchMaterials(String query) async {
    final maps = await _database.searchMaterials(query);
    return maps.map((map) => Material.fromMap(map)).toList();
  }

  Future<Map<String, double>> getCategoryWiseInventoryValue() async {
    return await _database.getCategoryWiseInventoryValue();
  }

  Future<Map<String, dynamic>> getMaterialStats() async {
    return await _database.getMaterialStats();
  }

  // ============ PRICE HISTORY ============
  Future<int> addMaterialPrice(Map<String, dynamic> price) async {
    return await _database.insertMaterialPrice(price);
  }

  Future<List<Map<String, dynamic>>> getMaterialPriceHistory(int materialId) async {
    return await _database.getMaterialPriceHistory(materialId);
  }

  // ============ BULK OPERATIONS ============
  Future<void> updateMaterialStock(int materialId, double newStock) async {
    final material = await getMaterialById(materialId);
    if (material != null) {
      material.currentStock = newStock;
      await updateMaterial(material);
    }
  }

  Future<void> adjustMaterialStock(int materialId, double adjustment) async {
    final material = await getMaterialById(materialId);
    if (material != null) {
      material.currentStock += adjustment;
      await updateMaterial(material);
    }
  }

  // ============ REPORTING ============
  Future<List<Map<String, dynamic>>> generateInventoryReport() async {
    final materials = await getAllMaterials();
    return materials.map((material) {
      return {
        'id': material.id,
        'name': material.name,
        'code': material.code,
        'category': material.categoryId,
        'stock': material.currentStock,
        'unit': material.unit,
        'unit_price': material.unitPrice,
        'total_value': material.totalValue,
        'min_stock': material.minStockLevel,
        'max_stock': material.maxStockLevel,
        'is_low_stock': material.isLowStock,
      };
    }).toList();
  }
}