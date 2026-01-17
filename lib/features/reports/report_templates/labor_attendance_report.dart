import 'package:flutter/material.dart';

class LaborAttendanceReport extends StatelessWidget {
  const LaborAttendanceReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Labor Attendance Report'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Labor Attendance Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}