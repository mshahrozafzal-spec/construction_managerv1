// lib/features/expenses/expense_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/data/local/db_helper.dart';

class ExpenseSummaryScreen extends StatelessWidget {
  final int projectId;

  const ExpenseSummaryScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getExpensesByProject(projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final expenses = snapshot.data ?? [];

        // Group expenses by category
        Map<String, double> categoryTotals = {};
        for (var ExpenseModel in expenses) {
          final category = ExpenseModel['category'] as String? ?? 'Uncategorized';
          final amount = (ExpenseModel['amount'] as num?)?.toDouble() ?? 0.0;
          categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('ExpenseModel Summary'),
          ),
          body: ListView(
            children: [
              for (var entry in categoryTotals.entries)
                Card(
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getExpensesByProject(int projectId) async {
    final dbHelper = DBHelper();
    final expenses = await dbHelper.getAllExpenses();

    // Filter by ProjectModel
    return expenses.where((ExpenseModel) {
      final expProjectId = ExpenseModel['project_id'];
      return expProjectId == projectId;
    }).toList();
  }
}
