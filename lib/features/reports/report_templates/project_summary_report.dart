import 'package:flutter/material.dart';
import 'package:construction_manager/database/models/project.dart';

class ProjectSummaryReport extends StatelessWidget {
  final Project project;

  const ProjectSummaryReport({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Summary Report'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.summarize, // Changed from Icons.summary
              color: Colors.blue,
              size: 40,
            ),
            const SizedBox(height: 20),
            Text(
              'Project Summary: ${project.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Client: ${project.clientName}'),
            Text('Location: ${project.location}'),
            Text('Status: ${project.status}'),
            Text('Progress: ${project.progress}%'),
          ],
        ),
      ),
    );
  }
}