// lib/main.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database using singleton
  final dbHelper = DBHelper();
  await dbHelper.init();  // Changed from dbHelper.database to dbHelper.init()

  runApp(const ConstructionManagerApp());
}