import 'package:flutter/material.dart';

class ProjectDetailScreen extends StatelessWidget {
  final dynamic project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project['name'] ?? 'Project Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                    _buildDetailRow('Project Name', project['name'] ?? 'N/A'),
                    _buildDetailRow('Description', project['description'] ?? 'N/A'),
                    _buildDetailRow('Status', project['status'] ?? 'N/A'),
                    _buildDetailRow('Progress', '${project['progress']?.toStringAsFixed(1) ?? '0'}%'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Financial Information Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Budget', '₹${(project['budget'] ?? 0).toStringAsFixed(2)}'),
                    _buildDetailRow('Spent', '₹${(project['spent'] ?? 0).toStringAsFixed(2)}'),
                    _buildDetailRow('Remaining', '₹${((project['budget'] ?? 0) - (project['spent'] ?? 0)).toStringAsFixed(2)}'),
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
                    _buildDetailRow('Start Date', _formatDate(project['startDate'])),
                    if (project['endDate'] != null)
                      _buildDetailRow('End Date', _formatDate(project['endDate'])),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Client Information Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Client Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Client Name', project['clientName'] ?? 'N/A'),
                    _buildDetailRow('Contact Person', project['contactPerson'] ?? 'N/A'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Site Location', project['location'] ?? 'N/A'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes Card
            if (project['notes'] != null && (project['notes'] as String).isNotEmpty)
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
                      Text(project['notes'] ?? ''),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
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
    if (date == null) return 'N/A';
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
}