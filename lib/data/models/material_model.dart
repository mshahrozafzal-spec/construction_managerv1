// lib/data/models/material_model.dart
class Material {
  int? id;
  String name;
  String? code;
  String? description;
  int? categoryId;
  double currentStock;
  String unit;
  double? minStockLevel;
  double? maxStockLevel;
  double? unitPrice;
  int? supplierId;
  String? specifications;
  String? imageUrl;
  String? notes;
  DateTime createdAt;

  Material({
    this.id,
    required this.name,
    this.code,
    this.description,
    this.categoryId,
    this.currentStock = 0,
    this.unit = 'pieces',
    this.minStockLevel = 5,
    this.maxStockLevel = 100,
    this.unitPrice,
    this.supplierId,
    this.specifications,
    this.imageUrl,
    this.notes,
    required this.createdAt,
  });

  factory Material.fromMap(Map<String, dynamic> map) {
    return Material(
      id: map['id'] as int?,
      name: map['name'] as String,
      code: map['code'] as String?,
      description: map['description'] as String?,
      categoryId: map['category_id'] as int?,
      currentStock: (map['current_stock'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'pieces',
      minStockLevel: (map['min_stock_level'] as num?)?.toDouble(),
      maxStockLevel: (map['max_stock_level'] as num?)?.toDouble(),
      unitPrice: (map['unit_price'] as num?)?.toDouble(),
      supplierId: map['supplier_id'] as int?,
      specifications: map['specifications'] as String?,
      imageUrl: map['image_url'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      'current_stock': currentStock,
      'unit': unit,
      if (minStockLevel != null) 'min_stock_level': minStockLevel,
      if (maxStockLevel != null) 'max_stock_level': maxStockLevel,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (supplierId != null) 'supplier_id': supplierId,
      if (specifications != null) 'specifications': specifications,
      if (imageUrl != null) 'image_url': imageUrl,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get totalValue => currentStock * (unitPrice ?? 0);
  bool get isLowStock => minStockLevel != null && currentStock <= minStockLevel!;

  @override
  String toString() {
    return 'Material(id: $id, name: $name, stock: $currentStock $unit, price: $unitPrice)';
  }
}