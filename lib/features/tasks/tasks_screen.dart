// lib/features/tasks/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/data/local/db_helper.dart';
import 'package:construction_manager/features/tasks/add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _filteredTasks = [];
  bool _isLoading = true;
  String _filterStatus = 'All';
  final List<String> _statusOptions = ['All', 'pending', 'in_progress', 'completed', 'on_hold'];
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _tasks = await _dbHelper.getTasks();
      _applyFilter();
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_filterStatus == 'All') {
      _filteredTasks = _tasks;
    } else {
      _filteredTasks = _tasks.where((TaskModel) {
        final status = TaskModel['status']?.toString().toLowerCase() ?? '';
        return status == _filterStatus.toLowerCase();
      }).toList();
    }
  }

  // Helper method to convert string to title case
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split('_')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : word)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
                _applyFilter();
              });
            },
            itemBuilder: (context) => _statusOptions.map((status) {
              return PopupMenuItem<String>(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_toTitleCase(status)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTasks.isEmpty
          ? _buildEmptyState()
          : _buildTasksList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.task, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No tasks yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first TaskModel',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _addNewTask,
            child: const Text('Create TaskModel'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        itemCount: _filteredTasks.length,
        itemBuilder: (context, index) {
          final TaskModel = _filteredTasks[index];
          return _buildTaskCard(TaskModel);
        },
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> TaskModel) {
    final title = TaskModel['title'] ?? 'Untitled TaskModel';
    final status = TaskModel['status']?.toString() ?? 'pending';
    final priority = TaskModel['priority']?.toString() ?? 'medium';
    final startDate = TaskModel['start_date']?.toString() ?? '';
    final endDate = TaskModel['end_date']?.toString() ?? '';
    final estimatedHours = (TaskModel['estimated_hours'] as num?)?.toDouble() ?? 0.0;
    final actualHours = (TaskModel['actual_hours'] as num?)?.toDouble() ?? 0.0;
    final taskId = TaskModel['id'] as int? ?? 0;

    final progress = estimatedHours > 0 ? (actualHours / estimatedHours).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(priority).withAlpha(25),
          child: Icon(
            Icons.task,
            color: _getPriorityColor(priority),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Status: ${_toTitleCase(status)}'),
            if (startDate.isNotEmpty && endDate.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Due: ${_formatDate(endDate)}'),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStatusColor(status),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(progress * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Est: ${estimatedHours.toStringAsFixed(1)}h'),
                Text('Act: ${actualHours.toStringAsFixed(1)}h'),
                Chip(
                  label: Text(_toTitleCase(priority)),
                  backgroundColor: _getPriorityColor(priority).withAlpha(25),
                  labelStyle: TextStyle(color: _getPriorityColor(priority)),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTaskAction(value, taskId, TaskModel),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'complete',
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Mark Complete'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _viewTaskDetails(TaskModel),
        onLongPress: () => _showTaskOptions(TaskModel),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'on_hold':
        return Colors.yellow;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _handleTaskAction(String action, int taskId, Map<String, dynamic> TaskModel) {
    switch (action) {
      case 'edit':
        _editTask(TaskModel);
        break;
      case 'complete':
        _completeTask(taskId);
        break;
      case 'delete':
        _deleteTask(taskId);
        break;
    }
  }

  void _addNewTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    ).then((value) {
      if (value == true) {
        _loadTasks(); // Reload tasks after adding
      }
    });
  }

  void _editTask(Map<String, dynamic> TaskModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit TaskModel screen coming soon')),
    );
  }

  void _viewTaskDetails(Map<String, dynamic> TaskModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TaskModel Details screen coming soon')),
    );
  }

  void _showTaskOptions(Map<String, dynamic> TaskModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit TaskModel'),
                onTap: () {
                  Navigator.pop(context);
                  _editTask(TaskModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.green),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _viewTaskDetails(TaskModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Mark Complete'),
                onTap: () {
                  Navigator.pop(context);
                  _completeTask(TaskModel['id'] as int);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete TaskModel',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTask(TaskModel['id'] as int);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completeTask(int taskId) async {
    try {
      await _dbHelper.updateTask(taskId, {
        'status': 'completed',
        'completed_date': DateTime.now().toIso8601String(),
      });
      _loadTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TaskModel marked as completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing TaskModel: $e')),
      );
    }
  }

  Future<void> _deleteTask(int taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete TaskModel'),
        content: const Text('Are you sure you want to delete this TaskModel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteTask(taskId);
        _loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TaskModel deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting TaskModel: $e')),
        );
      }
    }
  }
}
