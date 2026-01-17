import 'package:flutter/material.dart';
import 'package:construction_manager/database/models/task.dart';

class GanttChartWidget extends StatelessWidget {
  final List<Task> tasks;

  const GanttChartWidget({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(task.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${task.type}'),
                Text('Status: ${task.status}'),
                Text('Start: ${task.startDate.toLocal().toString().split(' ')[0]}'),
                if (task.endDate != null)
                  Text('End: ${task.endDate!.toLocal().toString().split(' ')[0]}'),
                Text('Progress: ${task.progress}%'),
              ],
            ),
            trailing: Chip(
              label: Text(task.priority),
              backgroundColor: task.getPriorityColor().withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }
}