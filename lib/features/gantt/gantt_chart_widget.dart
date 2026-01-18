import 'package:flutter/material.dart';
import 'package:construction_manager/data/models/task_model.dart';

class GanttChartWidget extends StatelessWidget {
  final List<TaskModel> tasks;

  const GanttChartWidget({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final TaskModel = tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(TaskModel.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${TaskModel.type}'),
                Text('Status: ${TaskModel.status}'),
                Text('Start: ${TaskModel.startDate.toLocal().toString().split(' ')[0]}'),
                if (TaskModel.endDate != null)
                  Text('End: ${TaskModel.endDate!.toLocal().toString().split(' ')[0]}'),
                Text('Progress: ${TaskModel.progress}%'),
              ],
            ),
            trailing: Chip(
              label: Text(TaskModel.priority),
              backgroundColor: TaskModel.getPriorityColor().withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }
}
