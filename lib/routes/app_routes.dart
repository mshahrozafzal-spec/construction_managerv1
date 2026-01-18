import 'package:flutter/material.dart';
import 'package:construction_manager/features/dashboard/dashboard_screen.dart';
import 'package:construction_manager/features/materials/screens/add_material_screen.dart';
import 'package:construction_manager/features/materials/screens/material_catalog_screen.dart';
import 'package:construction_manager/features/materials/screens/cost_control_screen.dart';
import 'package:construction_manager/features/projects/project_form_screen.dart';
import 'package:construction_manager/features/projects/project_detail_screen.dart';
import 'package:construction_manager/features/tasks/task_form_screen.dart';
import 'package:construction_manager/features/tasks/task_detail_screen.dart';
import 'package:construction_manager/features/labor/labor_form_screen.dart';
import 'package:construction_manager/features/reports/reports_screen.dart';
import 'package:construction_manager/features/reports/report_templates/expense_report.dart';
import 'package:construction_manager/features/reports/report_templates/project_summary_report.dart';

class AppRoutes {
  // Route names
  static const String addExpense = '/expenses/add';
  static const String dashboard = '/';
  static const String materialCatalog = '/materials';
  static const String addMaterial = '/materials/add';
  static const String editMaterial = '/materials/edit';
  static const String costControl = '/materials/cost-control';
  static const String projects = '/projects';
  static const String addProject = '/projects/add';
  static const String editProject = '/projects/edit';
  static const String projectDetail = '/projects/detail';
  static const String tasks = '/tasks';
  static const String addTask = '/tasks/add';
  static const String editTask = '/tasks/edit';
  static const String taskDetail = '/tasks/detail';
  static const String labor = '/labor';
  static const String addLabor = '/labor/add';
  static const String editLabor = '/labor/edit';
  static const String reports = '/reports';
  static const String expenseReport = '/reports/expense';
  static const String projectSummaryReport = '/reports/project-summary';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case materialCatalog:
        return MaterialPageRoute(builder: (_) => const MaterialCatalogScreen());

      case addMaterial:
        return MaterialPageRoute(builder: (_) => const AddMaterialScreen());

      case editMaterial:
        final material = settings.arguments as Map<String, dynamic>?;
        // TODO: Create EditMaterialScreen
        return MaterialPageRoute(
          builder: (_) => const AddMaterialScreen(), // Temporary
        );

      case costControl:
        return MaterialPageRoute(builder: (_) => const CostControlScreen());

      case addProject:
        return MaterialPageRoute(builder: (_) => const ProjectFormScreen());

      case editProject:
        final project = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProjectFormScreen(project: project != null ? _convertToProjectModel(project) : null),
        );

      case projectDetail:
        final project = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(project: project),
        );

      case addTask:
        return MaterialPageRoute(builder: (_) => const TaskFormScreen());

      case editTask:
        final task = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TaskFormScreen(task: task),
        );

      case taskDetail:
        final task = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TaskDetailScreen(task: task),
        );

      case addLabor:
        return MaterialPageRoute(builder: (_) => const LaborFormScreen());

      case editLabor:
        final labor = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LaborFormScreen(labor: labor),
        );

      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());

      case expenseReport:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ExpenseReport(
            expenses: args['expenses'] ?? [],
            startDate: args['startDate'] ?? DateTime.now().subtract(const Duration(days: 30)),
            endDate: args['endDate'] ?? DateTime.now(),
            reportTitle: args['title'] ?? 'Expense Report',
          ),
        );

      case projectSummaryReport:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ProjectSummaryReport(
            projects: args['projects'] ?? [],
            startDate: args['startDate'] ?? DateTime.now().subtract(const Duration(days: 30)),
            endDate: args['endDate'] ?? DateTime.now(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }

  // Helper method to convert Map to ProjectModel-like object
  static dynamic _convertToProjectModel(Map<String, dynamic> data) {
    // This is a simplified conversion
    return {
      'id': data['id'],
      'name': data['name'],
      'description': data['description'],
      'startDate': data['startDate'],
      'endDate': data['endDate'],
      'budget': data['budget'],
      'clientName': data['clientName'],
      'contactPerson': data['contactPerson'],
      'notes': data['notes'],
      'status': data['status'],
      'progress': data['progress'],
      'location': data['location'],
      'spent': data['spent'],
    };
  }
}