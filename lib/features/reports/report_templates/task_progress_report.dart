import 'package:flutter/material.dart';

class TaskProgressReport extends StatelessWidget {
  const TaskProgressReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Progress Report'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 100, color: Colors.purple),
            SizedBox(height: 20),
            Text(
              'Task Progress Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}