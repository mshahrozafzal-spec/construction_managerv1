// lib/data/models/expenses.dart
class ExpenseModel {
  final int? id;
  final int? projectId;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String? receiptImage;
  final String? notes;
  final DateTime createdAt;

  ExpenseModel({
    this.id,
    this.projectId,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.receiptImage,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'receipt_image': receiptImage,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      projectId: map['project_id'] as int?,
      category: map['category'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      receiptImage: map['receipt_image'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
