// lib/features/gantt/gantt_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/database/models/task.dart';
import 'package:construction_manager/database/repositories/task_repository.dart';
import 'package:construction_manager/features/gantt/gantt_chart_widget.dart';

class GanttScreen extends StatefulWidget {
  final int? projectId;

  const GanttScreen({super.key, this.projectId});

  @override
  State<GanttScreen> createState() => _GanttScreenState();
}

class _GanttScreenState extends State<GanttScreen> {
  late Future<List<Task>> _tasksFuture;
  late TaskRepository _taskRepository;

  @override
  void initState() {
    super.initState();
    _taskRepository = TaskRepository();
    _loadTasks();
  }

  void _loadTasks() {
    if (widget.projectId != null) {
      _tasksFuture = _taskRepository.getTasksByProject(widget.projectId!);
    } else {
      _tasksFuture = _taskRepository.getAllTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gantt Chart'),
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];

          // Fixed: Handle nullable endDate properly
          final now = DateTime.now();
          final upcomingTasks = tasks.where((task) {
            // Check if task is upcoming (starts in next 7 days)
            return task.startDate.isAfter(now) &&
                task.startDate.isBefore(now.add(const Duration(days: 7)));
          }).toList();

          // Fixed: Handle null endDate properly
          final delayedTasks = tasks.where((task) {
            if (task.endDate == null) return false;
            // Fixed: Check if task is delayed (past end date and not completed)
            return task.endDate!.isBefore(now) && task.status != 'Completed';
          }).toList();

          // Fixed: Calculate duration only if endDate is not null
          for (final task in tasks) {
            if (task.endDate != null) {
              final duration = task.endDate!.difference(task.startDate).inDays;
              // Fixed: Use isDelayed property
              if (task.isDelayed) {
                print('Task "${task.title}" is delayed by ${duration} days');
              }
            }
          }

          return Column(
            children: [
              // Statistics
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Total Tasks', tasks.length.toString()),
                    _buildStatCard('Upcoming', upcomingTasks.length.toString()),
                    _buildStatCard('Delayed', delayedTasks.length.toString()),
                  ],
                ),
              ),

              // Fixed: GanttChartWidget with correct parameters
              Expanded(
                child: GanttChartWidget(
                  tasks: tasks,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}