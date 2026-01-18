// lib/data/models/task_model.dart
import 'package:flutter/material.dart';

class TaskModel {
  final int? id;
  final int? projectId;
  final String title;
  final String description;
  final String type;
  final String status;
  final String priority;
  final DateTime startDate;
  final DateTime? endDate;
  final int progress;
  final String? assignedTo;
  final int? dependsOnTaskId;
  final double estimatedHours;
  final double actualHours;
  final String? notes;
  final String? location;

  const TaskModel({
    this.id,
    this.projectId,
    required this.title,
    this.description = '',
    required this.type,
    required this.status,
    required this.priority,
    required this.startDate,
    this.endDate,
    this.progress = 0,
    this.assignedTo,
    this.dependsOnTaskId,
    this.estimatedHours = 0.0,
    this.actualHours = 0.0,
    this.notes,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'priority': priority,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'progress': progress,
      'assigned_to': assignedTo,
      'depends_on_task_id': dependsOnTaskId,
      'estimated_hours': estimatedHours,
      'actual_hours': actualHours,
      'notes': notes,
      'location': location,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      projectId: map['project_id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      type: map['type'] as String,
      status: map['status'] as String,
      priority: map['priority'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      progress: map['progress'] as int,
      assignedTo: map['assigned_to'] as String?,
      dependsOnTaskId: map['depends_on_task_id'] as int?,
      estimatedHours: (map['estimated_hours'] as num?)?.toDouble() ?? 0.0,
      actualHours: (map['actual_hours'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String?,
      location: map['location'] as String?,
    );
  }

  static final Map<String, Color> statusColors = {
    'Not Started': Colors.grey,
    'In Progress': Colors.blue,
    'Completed': Colors.green,
    'On Hold': Colors.orange,
    'Cancelled': Colors.red,
  };

  static final Map<String, Color> priorityColors = {
    'Low': Colors.green,
    'Medium': Colors.amber,
    'High': Colors.orange,
    'Critical': Colors.red,
  };

  Color getStatusColor() {
    return statusColors[status] ?? Colors.grey;
  }

  Color getPriorityColor() {
    return priorityColors[priority] ?? Colors.grey;
  }

  TaskModel copyWith({
    int? id,
    int? projectId,
    String? title,
    String? description,
    String? type,
    String? status,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
    int? progress,
    String? assignedTo,
    int? dependsOnTaskId,
    double? estimatedHours,
    double? actualHours,
    String? notes,
    String? location,
  }) {
    return TaskModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      assignedTo: assignedTo ?? this.assignedTo,
      dependsOnTaskId: dependsOnTaskId ?? this.dependsOnTaskId,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      notes: notes ?? this.notes,
      location: location ?? this.location,
    );
  }

  bool get isDelayed {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!) && status != 'Completed';
  }

  double get progressPercent => progress.toDouble();
  String get formattedEstimatedHours => '${estimatedHours}h';
  String get formattedActualHours => '${actualHours}h';
}
