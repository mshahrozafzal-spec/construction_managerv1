// lib/features/projects/project_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/database/models/project.dart';
import 'package:construction_manager/database/models/task.dart';
import 'package:construction_manager/database/models/labor.dart';
import 'package:construction_manager/database/repositories/task_repository.dart';
import 'package:construction_manager/database/repositories/labor_repository.dart';
import 'package:construction_manager/features/expenses/add_expense_screen.dart';
import 'package:construction_manager/features/expenses/expenses_screen.dart';
import 'package:construction_manager/features/tasks/add_task_screen.dart';
import 'package:construction_manager/features/labor/add_labor_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late TaskRepository _taskRepository;
  late LaborRepository _laborRepository;
  List<Task> _tasks = [];
  List<Labor> _labors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _taskRepository = TaskRepository();
    _laborRepository = LaborRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.project.id != null) {
        _tasks = await _taskRepository.getTasksByProject(widget.project.id!);
        _labors = await _laborRepository.getLaborsByProject(widget.project.id!);
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Project details section
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Client: ${widget.project.clientName}'),
                    Text('Contact: ${widget.project.contactPerson}'),
                    Text('Location: ${widget.project.location}'),
                    Text('Budget: \$${widget.project.budget.toStringAsFixed(2)}'),
                    Text('Spent: \$${widget.project.spent.toStringAsFixed(2)}'),
                    Text('Remaining: \$${(widget.project.budget - widget.project.spent).toStringAsFixed(2)}'),
                    Text('Progress: ${widget.project.progress.toStringAsFixed(1)}%'),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: widget.project.progress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.project.progress >= 100
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tasks section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tasks (${_tasks.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskScreen(),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _loadData();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            if (_tasks.isNotEmpty)
              ..._tasks.map((task) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text('Status: ${task.status} • Progress: ${task.progress}%'),
                  trailing: Chip(
                    label: Text(task.priority),
                    backgroundColor: task.getPriorityColor().withOpacity(0.2),
                  ),
                ),
              )).toList()
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No tasks yet'),
              ),

            // Labor section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Labor (${_labors.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddLaborScreen(),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _loadData();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            if (_labors.isNotEmpty)
              ..._labors.map((labor) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(labor.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role: ${labor.role}'),
                      Text('Monthly Wage: \$${labor.monthlyWage.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(labor.status),
                    backgroundColor: labor.getStatusColor().withOpacity(0.2),
                  ),
                ),
              )).toList()
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No labor assigned'),
              ),

            // Expenses section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expenses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExpenseScreen(projectId: widget.project.id),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Expense navigation button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpensesScreen(projectId: widget.project.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('View All Expenses'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}