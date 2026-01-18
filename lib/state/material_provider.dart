import 'package:flutter/material.dart';
import 'package:construction_manager/data/repositories/material_repository.dart';
import 'package:construction_manager/data/models/material_model.dart';
import 'package:construction_manager/data/models/material_category_model.dart';
import 'package:construction_manager/data/models/supplier_model.dart';

class MaterialProvider extends ChangeNotifier {
  final MaterialRepository _repository;

  // State variables
  List<MaterialModel> _materials = [];
  List<MaterialCategoryModel> _categories = [];
  List<SupplierModel> _suppliers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters
  List<MaterialModel> get materials => _materials;
  List<MaterialCategoryModel> get categories => _categories;
  List<SupplierModel> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Computed properties
  double get totalInventoryValue => _materials.fold(
    0.0,
        (sum, material) => sum + material.totalValue,
  );

  List<MaterialModel> get lowStockMaterials =>
      _materials.where((m) => m.isLowStock).toList();

  List<MaterialModel> get filteredMaterials {
    var filtered = _materials;

    // Apply category filter
    if (_selectedCategory != 'All') {
      final category = _categories.firstWhere(
            (c) => c.name == _selectedCategory,
        orElse: () => MaterialCategoryModel(name: '', createdAt: DateTime.now()),
      );
      if (category.id != null) {
        filtered = filtered.where((m) => m.categoryId == category.id).toList();
      } else {
        // Handle 'All' category or uncategorized
        if (_selectedCategory == 'Uncategorized') {
          filtered = filtered.where((m) => m.categoryId == null).toList();
        }
      }
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((material) {
        return material.name.toLowerCase().contains(query) ||
            (material.code?.toLowerCase().contains(query) ?? false) ||
            (material.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  // Constructor
  MaterialProvider({MaterialRepository? repository})
      : _repository = repository ?? MaterialRepository();

  // ============ STATE MANAGEMENT METHODS ============

  /// Load all material data
  Future<void> loadMaterials() async {
    _setLoading(true);
    try {
      _materials = await _repository.getAllMaterials();
      _categories = await _repository.getAllCategories();
      _suppliers = await _repository.getAllSuppliers();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load materials: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Add new material
  Future<void> addMaterial(MaterialModel material) async {
    _setLoading(true);
    try {
      await _repository.addMaterial(material);
      await loadMaterials(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = 'Failed to add material: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update existing material
  Future<void> updateMaterial(MaterialModel material) async {
    _setLoading(true);
    try {
      await _repository.updateMaterial(material);
      await loadMaterials();
      _error = null;
    } catch (e) {
      _error = 'Failed to update material: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete material
  Future<void> deleteMaterial(int id) async {
    _setLoading(true);
    try {
      await _repository.deleteMaterial(id);
      await loadMaterials();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete material: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Add new supplier
  Future<void> addSupplier(SupplierModel supplier) async {
    _setLoading(true);
    try {
      await _repository.addSupplier(supplier);
      _suppliers = await _repository.getAllSuppliers();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add supplier: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Add new category
  Future<void> addCategory(MaterialCategoryModel category) async {
    _setLoading(true);
    try {
      await _repository.addCategory(category);
      _categories = await _repository.getAllCategories();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add category: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ============ COST CONTROL METHODS ============

  Future<double> getTotalInventoryValueAsync() async {
    return await _repository.getTotalInventoryValue();
  }

  Future<Map<String, double>> getCategoryWiseInventoryValueAsync() async {
    return await _repository.getCategoryWiseInventoryValue();
  }

  Future<Map<String, dynamic>> getMaterialStatsAsync() async {
    return await _repository.getMaterialStats();
  }

  Future<List<Map<String, dynamic>>> generateInventoryReportAsync() async {
    return await _repository.generateInventoryReport();
  }

  // ============ UTILITY METHODS ============

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    notifyListeners();
  }

  MaterialModel? findMaterialById(int id) {
    try {
      return _materials.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  MaterialCategoryModel? findCategoryById(int? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  SupplierModel? findSupplierById(int? id) {
    if (id == null) return null;
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> adjustStock(int materialId, double adjustment) async {
    _setLoading(true);
    try {
      await _repository.adjustMaterialStock(materialId, adjustment);
      await loadMaterials();
      _error = null;
    } catch (e) {
      _error = 'Failed to adjust stock: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ============ PRIVATE METHODS ============

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}