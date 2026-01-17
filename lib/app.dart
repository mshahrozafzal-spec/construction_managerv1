// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/state/providers/project_provider.dart';
import 'package:construction_manager/state/providers/task_provider.dart';
import 'package:construction_manager/state/material_provider.dart'; // ADDED THIS LINE
import 'package:construction_manager/features/dashboard/dashboard_screen.dart';

class ConstructionManagerApp extends StatelessWidget {
  const ConstructionManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProjectProvider(dbHelper: DBHelper()),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(dbHelper: DBHelper()),
        ),
        // Add MaterialProvider - ADDED THESE 4 LINES
        ChangeNotifierProvider(
          create: (context) => MaterialProvider(),
        ),
        // Add other providers as needed
      ],
      child: MaterialApp(
        title: 'Construction Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}