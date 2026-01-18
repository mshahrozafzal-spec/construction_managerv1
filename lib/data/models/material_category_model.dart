class MaterialCategoryModel {
  int? id;
  String name;
  String? description;
  String? parentCategory;
  String? icon;
  DateTime createdAt;

  MaterialCategoryModel({
    this.id,
    required this.name,
    this.description,
    this.parentCategory,
    this.icon,
    required this.createdAt,
  });

  factory MaterialCategoryModel.fromMap(Map<String, dynamic> map) {
    return MaterialCategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      parentCategory: map['parent_category'] as String?,
      icon: map['icon'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (parentCategory != null) 'parent_category': parentCategory,
      if (icon != null) 'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MaterialCategoryModel(id: $id, name: $name)';
  }
}