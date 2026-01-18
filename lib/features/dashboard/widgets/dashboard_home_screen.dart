import 'package:flutter/material.dart';
import 'package:construction_manager/data/models/project_model.dart';

class DashboardHomeScreen extends StatelessWidget {
  final List<ProjectModel> projects;

  const DashboardHomeScreen({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final ProjectModel = projects[index];
        return Card(
          child: ListTile(
            title: Text(ProjectModel.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed: Changed from ProjectModel.client to ProjectModel.clientName
                Text(ProjectModel.clientName),
                Text('Progress: ${ProjectModel.progress.toStringAsFixed(1)}%'),
              ],
            ),
            trailing: Chip(
              label: Text(ProjectModel.status),
              backgroundColor: ProjectModel.status == 'Active'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }
}
