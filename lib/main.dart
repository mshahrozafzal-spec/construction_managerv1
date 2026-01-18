// lib/main.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/data/local/db_helper.dart';
import 'package:construction_manager/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final dbHelper = DBHelper();
  await dbHelper.init();

  runApp(const ConstructionManagerApp());
}
