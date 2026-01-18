import 'package:flutter/material.dart';

class TaskCalendarScreen extends StatelessWidget {
  const TaskCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskModel Calendar'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'TaskModel Calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('View tasks on a calendar'),
          ],
        ),
      ),
    );
  }
}
