import 'package:flutter/material.dart';

class ProjectSummaryReport extends StatelessWidget {
  final List<dynamic> projects;
  final DateTime startDate;
  final DateTime endDate;

  const ProjectSummaryReport({
    super.key,
    required this.projects,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final activeProjects = projects.where((p) => p['status'] == 'Active').length;
    final completedProjects = projects.where((p) => p['status'] == 'Completed').length;
    final totalBudget = projects.fold(0.0, (sum, project) => sum + (project['budget'] ?? 0));
    final totalSpent = projects.fold(0.0, (sum, project) => sum + (project['spent'] ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Summary Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReport(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Header
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project Summary Report',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Period: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Generated on: ${_formatDate(DateTime.now())}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildSummaryCard(
                  'Total Projects',
                  projects.length.toString(),
                  Icons.work,
                  Colors.blue,
                ),
                _buildSummaryCard(
                  'Active Projects',
                  activeProjects.toString(),
                  Icons.play_arrow,
                  Colors.green,
                ),
                _buildSummaryCard(
                  'Completed',
                  completedProjects.toString(),
                  Icons.check_circle,
                  Colors.teal,
                ),
                _buildSummaryCard(
                  'Total Budget',
                  '₹${totalBudget.toStringAsFixed(2)}',
                  Icons.currency_rupee,
                  Colors.purple,
                ),
                _buildSummaryCard(
                  'Total Spent',
                  '₹${totalSpent.toStringAsFixed(2)}',
                  Icons.money_off,
                  Colors.orange,
                ),
                _buildSummaryCard(
                  'Remaining',
                  '₹${(totalBudget - totalSpent).toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Project Status Breakdown
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._groupByStatus().entries.map((entry) {
                      final percentage = projects.isNotEmpty ? (entry.value.length / projects.length * 100) : 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(entry.key),
                                ),
                                Text('${entry.value.length} projects'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getStatusColor(entry.key),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Project List
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...projects.map((project) {
                      final progress = project['progress'] ?? 0.0;
                      final budget = project['budget'] ?? 0.0;
                      final spent = project['spent'] ?? 0.0;
                      final remaining = budget - spent;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(project['status'] ?? 'Planning')
                              .withAlpha(25),
                          child: Icon(
                            Icons.work,
                            color: _getStatusColor(project['status'] ?? 'Planning'),
                          ),
                        ),
                        title: Text(project['name'] ?? 'Unnamed Project'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${project['status'] ?? 'N/A'}'),
                            Text('Progress: ${progress.toStringAsFixed(1)}%'),
                            Text('Budget: ₹${budget.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹${spent.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              '₹${remaining.toStringAsFixed(2)} left',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Export Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _exportReport(context),
                icon: const Icon(Icons.download),
                label: const Text('Export Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<dynamic>> _groupByStatus() {
    final Map<String, List<dynamic>> grouped = {};
    for (var project in projects) {
      final status = project['status'] ?? 'Unknown';
      if (!grouped.containsKey(status)) {
        grouped[status] = [];
      }
      grouped[status]!.add(project);
    }
    return grouped;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'planning':
        return Colors.blue;
      case 'on hold':
        return Colors.orange;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _printReport(BuildContext context) {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon')),
    );
  }

  void _shareReport(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _exportReport(BuildContext context) {
    // TODO: Implement PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export coming soon')),
    );
  }
}