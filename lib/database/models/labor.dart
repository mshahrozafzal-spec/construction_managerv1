import 'package:flutter/material.dart';

class Labor {
  final int? id;
  final String name;
  final String? contact;
  final String role;
  final double dailyWage;
  final double monthlyWage;
  final String paymentMethod;
  final String status;
  final String? notes;
  final int? projectId;
  final double totalAdvance;
  final String? idNumber;
  final String? address;
  final DateTime? joinDate;
  final String? skills;
  final String? emergencyContact;

  const Labor({
    this.id,
    required this.name,
    this.contact,
    required this.role,
    required this.dailyWage,
    required this.monthlyWage,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.projectId,
    required this.totalAdvance,
    this.idNumber,
    this.address,
    this.joinDate,
    this.skills,
    this.emergencyContact,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'role': role,
      'daily_wage': dailyWage,
      'monthly_wage': monthlyWage,
      'payment_method': paymentMethod,
      'status': status,
      'notes': notes,
      'project_id': projectId,
      'total_advance': totalAdvance,
      'id_number': idNumber,
      'address': address,
      'join_date': joinDate?.toIso8601String(),
      'skills': skills,
      'emergency_contact': emergencyContact,
    };
  }

  factory Labor.fromMap(Map<String, dynamic> map) {
    return Labor(
      id: map['id'] as int?,
      name: map['name'] as String,
      contact: map['contact'] as String?,
      role: map['role'] as String,
      dailyWage: (map['daily_wage'] as num).toDouble(),
      monthlyWage: (map['monthly_wage'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      status: map['status'] as String,
      notes: map['notes'] as String?,
      projectId: map['project_id'] as int?,
      totalAdvance: (map['total_advance'] as num).toDouble(),
      idNumber: map['id_number'] as String?,
      address: map['address'] as String?,
      joinDate: map['join_date'] != null ? DateTime.parse(map['join_date'] as String) : null,
      skills: map['skills'] as String?,
      emergencyContact: map['emergency_contact'] as String?,
    );
  }

  static final Map<String, Color> statusColors = {
    'Active': Colors.green,
    'Inactive': Colors.grey,
    'On Leave': Colors.orange,
    'Terminated': Colors.red,
    'Probation': Colors.yellow,
  };

  static final Map<String, Color> roleColors = {
    'Laborer': Colors.blue,
    'Supervisor': Colors.purple,
    'Foreman': Colors.orange,
    'Engineer': Colors.green,
    'Electrician': Colors.red,
    'Plumber': Colors.cyan,
    'Carpenter': Colors.brown,
    'Mason': Colors.amber,
  };

  Color getStatusColor() {
    return statusColors[status] ?? Colors.grey;
  }

  Color getRoleColor() {
    return roleColors[role] ?? Colors.grey;
  }

  Labor copyWith({
    int? id,
    String? name,
    String? contact,
    String? role,
    double? dailyWage,
    double? monthlyWage,
    String? paymentMethod,
    String? status,
    String? notes,
    int? projectId,
    double? totalAdvance,
    String? idNumber,
    String? address,
    DateTime? joinDate,
    String? skills,
    String? emergencyContact,
  }) {
    return Labor(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      role: role ?? this.role,
      dailyWage: dailyWage ?? this.dailyWage,
      monthlyWage: monthlyWage ?? this.monthlyWage,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      projectId: projectId ?? this.projectId,
      totalAdvance: totalAdvance ?? this.totalAdvance,
      idNumber: idNumber ?? this.idNumber,
      address: address ?? this.address,
      joinDate: joinDate ?? this.joinDate,
      skills: skills ?? this.skills,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  String get formattedDailyWage => '₹${dailyWage.toStringAsFixed(2)}';
  String get formattedMonthlyWage => '₹${monthlyWage.toStringAsFixed(2)}';
  String get formattedTotalAdvance => '₹${totalAdvance.toStringAsFixed(2)}';
}