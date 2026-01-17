import 'package:flutter/material.dart';
import 'package:construction_manager/database/models/project.dart';

class ExpenseReport extends StatelessWidget {
  final Project project;

  const ExpenseReport({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Report'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Expense Report for ${project.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Budget: ${project.formattedBudget}'),
            Text('Spent: ${project.formattedSpent}'),
            Text('Remaining: ${project.formattedRemaining}'),
          ],
        ),
      ),
    );
  }
}