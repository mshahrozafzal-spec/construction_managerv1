import 'dart:convert';

class Project {
  final int? id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final double budget;
  final String clientName;
  final String contactPerson;
  final String notes;
  final String status;
  final double progress;
  final String location;
  final double spent;

  const Project({
    this.id,
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.budget,
    required this.clientName,
    required this.contactPerson,
    required this.notes,
    required this.status,
    required this.progress,
    required this.location,
    required this.spent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'budget': budget,
      'client_name': clientName,
      'contact_person': contactPerson,
      'notes': notes,
      'status': status,
      'progress': progress,
      'location': location,
      'spent': spent,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      budget: (map['budget'] as num).toDouble(),
      clientName: map['client_name'] as String,
      contactPerson: map['contact_person'] as String,
      notes: map['notes'] as String,
      status: map['status'] as String,
      progress: (map['progress'] as num).toDouble(),
      location: map['location'] as String,
      spent: (map['spent'] as num).toDouble(),
    );
  }

  // Add copyWith method
  Project copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? clientName,
    String? contactPerson,
    String? notes,
    String? status,
    double? progress,
    String? location,
    double? spent,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      clientName: clientName ?? this.clientName,
      contactPerson: contactPerson ?? this.contactPerson,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      location: location ?? this.location,
      spent: spent ?? this.spent,
    );
  }

  // Add computed properties
  double get remainingBudget => budget - spent;
  String get formattedBudget => '₹${budget.toStringAsFixed(2)}';
  String get formattedSpent => '₹${spent.toStringAsFixed(2)}';
  String get formattedRemaining => '₹${remainingBudget.toStringAsFixed(2)}';

  // Alias for compatibility with old code
  String get client => clientName;
}