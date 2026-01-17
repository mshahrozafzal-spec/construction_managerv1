import 'package:flutter/material.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> expenseData;

  const ExpensePieChart({super.key, required this.expenseData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Install fl_chart package for visual charts',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            // Simple list view as placeholder
            if (expenseData.isNotEmpty)
              ...expenseData.entries.map((entry) => ListTile(
                title: Text(entry.key),
                trailing: Text('₹${entry.value.toStringAsFixed(2)}'),
              )).toList()
            else
              const Center(
                child: Text('No expense data'),
              ),
          ],
        ),
      ),
    );
  }
}