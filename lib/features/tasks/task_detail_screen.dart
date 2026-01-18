import 'package:flutter/material.dart';

class TaskDetailScreen extends StatelessWidget {
  final dynamic task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task['title'] ?? 'Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTask(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Information Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Title', task['title'] ?? 'N/A'),
                    _buildDetailRow('Description', task['description'] ?? 'No description'),
                    _buildDetailRow('Priority', task['priority'] ?? 'Medium'),
                    _buildDetailRow('Status', task['status'] ?? 'Pending'),
                    _buildDetailRow('Progress', '${task['progress']?.toStringAsFixed(1) ?? '0'}%'),
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
                    _buildDetailRow('Start Date', _formatDate(task['startDate'])),
                    _buildDetailRow('Due Date', _formatDate(task['dueDate'])),
                    if (task['completedDate'] != null)
                      _buildDetailRow('Completed Date', _formatDate(task['completedDate'])),
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
                    if (task['assignedTo'] != null)
                      _buildDetailRow('Assigned To', task['assignedTo']),
                    if (task['project'] != null)
                      _buildDetailRow('Project', task['project']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes Card
            if (task['notes'] != null && (task['notes'] as String).isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(task['notes'] ?? ''),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(context, 'In Progress'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(context, 'Completed'),
                    icon: const Icon(Icons.check),
                    label: const Text('Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Not set';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    if (date is String) {
      try {
        final parsed = DateTime.parse(date);
        return '${parsed.day}/${parsed.month}/${parsed.year}';
      } catch (e) {
        return date;
      }
    }
    return date.toString();
  }

  void _editTask(BuildContext context) {
    // TODO: Navigate to edit task screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit task feature coming soon')),
    );
  }

  void _updateStatus(BuildContext context, String newStatus) {
    // TODO: Update task status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task status updated to: $newStatus')),
    );
  }
}