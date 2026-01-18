import 'package:flutter/material.dart';

class ExpenseFormScreen extends StatelessWidget {
  final int projectId;

  const ExpenseFormScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add ExpenseModel')),
      body: const Center(
        child: Text('ExpenseModel Form - Coming Soon'),
      ),
    );
  }
}
