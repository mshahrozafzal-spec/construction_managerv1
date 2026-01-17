import 'package:flutter/material.dart';
import 'package:construction_manager/database/models/project.dart';

class DashboardHomeScreen extends StatelessWidget {
  final List<Project> projects;

  const DashboardHomeScreen({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          child: ListTile(
            title: Text(project.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed: Changed from project.client to project.clientName
                Text(project.clientName),
                Text('Progress: ${project.progress.toStringAsFixed(1)}%'),
              ],
            ),
            trailing: Chip(
              label: Text(project.status),
              backgroundColor: project.status == 'Active'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }
}