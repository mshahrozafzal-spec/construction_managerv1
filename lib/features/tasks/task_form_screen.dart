import 'package:flutter/material.dart';

class TaskFormScreen extends StatefulWidget {
  final dynamic task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _progressController = TextEditingController(text: '0');

  DateTime? _startDate;
  DateTime? _dueDate;
  String _priority = 'Medium';
  String _status = 'Pending';
  String? _selectedProject;
  String? _assignedTo;

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];
  final List<String> _statuses = ['Pending', 'In Progress', 'On Hold', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _loadExistingTask();
    } else {
      _setDefaultValues();
    }
  }

  void _loadExistingTask() {
    _titleController.text = widget.task['title'] ?? '';
    _descriptionController.text = widget.task['description'] ?? '';
    _notesController.text = widget.task['notes'] ?? '';
    _progressController.text = widget.task['progress']?.toStringAsFixed(0) ?? '0';
    _priority = widget.task['priority'] ?? 'Medium';
    _status = widget.task['status'] ?? 'Pending';
    _selectedProject = widget.task['project'];
    _assignedTo = widget.task['assignedTo'];

    if (widget.task['startDate'] != null) {
      if (widget.task['startDate'] is DateTime) {
        _startDate = widget.task['startDate'];
      } else if (widget.task['startDate'] is String) {
        try {
          _startDate = DateTime.parse(widget.task['startDate']);
        } catch (e) {
          _startDate = DateTime.now();
        }
      }
    }

    if (widget.task['dueDate'] != null) {
      if (widget.task['dueDate'] is DateTime) {
        _dueDate = widget.task['dueDate'];
      } else if (widget.task['dueDate'] is String) {
        try {
          _dueDate = DateTime.parse(widget.task['dueDate']);
        } catch (e) {
          // Keep as null
        }
      }
    }
  }

  void _setDefaultValues() {
    _startDate = DateTime.now();
    _priority = 'Medium';
    _status = 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Task Title *',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Task title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Priority & Status Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priority & Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _priority,
                              decoration: InputDecoration(
                                labelText: 'Priority *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _priorities.map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority),
                              )).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _priority = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: InputDecoration(
                                labelText: 'Status *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _statuses.map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              )).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _status = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _progressController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Progress %',
                          prefixIcon: const Icon(Icons.trending_up),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Progress is required';
                          }
                          final progress = double.tryParse(value);
                          if (progress == null || progress < 0 || progress > 100) {
                            return 'Progress must be between 0-100';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Timeline Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Timeline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectStartDate(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Start Date *',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _startDate == null
                                          ? 'Select Date'
                                          : _formatDate(_startDate!),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDueDate(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Due Date',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _dueDate == null
                                          ? 'Select Date'
                                          : _formatDate(_dueDate!),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Assignment Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assignment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: TextEditingController(text: _selectedProject ?? ''),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Project',
                          prefixIcon: const Icon(Icons.work),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _selectProject(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: TextEditingController(text: _assignedTo ?? ''),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Assigned To',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _selectAssignee(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: const Icon(Icons.note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Task',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectProject(BuildContext context) async {
    // TODO: Implement project selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project selection coming soon')),
    );
  }

  Future<void> _selectAssignee(BuildContext context) async {
    // TODO: Implement assignee selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignee selection coming soon')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate() && _startDate != null) {
      final task = {
        'id': widget.task?['id'],
        'title': _titleController.text,
        'description': _descriptionController.text,
        'priority': _priority,
        'status': _status,
        'progress': double.tryParse(_progressController.text) ?? 0.0,
        'startDate': _startDate,
        'dueDate': _dueDate,
        'project': _selectedProject,
        'assignedTo': _assignedTo,
        'notes': _notesController.text,
        'createdAt': DateTime.now(),
      };

      try {
        // TODO: Save task to database
        print('Saving task: $task');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}