// lib/features/expenses/expense_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/database/db_helper.dart';

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
        for (var expense in expenses) {
          final category = expense['category'] as String? ?? 'Uncategorized';
          final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
          categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expense Summary'),
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

    // Filter by project
    return expenses.where((expense) {
      final expProjectId = expense['project_id'];
      return expProjectId == projectId;
    }).toList();
  }
}