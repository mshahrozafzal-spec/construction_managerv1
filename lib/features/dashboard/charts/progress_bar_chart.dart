import 'package:flutter/material.dart';

class ProgressBarChart extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ProgressBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Install fl_chart package for visual charts',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            // Simple progress indicators
            Column(
              children: [
                _buildProgressRow('Completed Tasks', stats['completed'] ?? 0, stats['total'] ?? 1, Colors.green),
                _buildProgressRow('In Progress', stats['inProgress'] ?? 0, stats['total'] ?? 1, Colors.blue),
                _buildProgressRow('Not Started', stats['notStarted'] ?? 0, stats['total'] ?? 1, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text('$value/$total ($percentage%)'),
          const SizedBox(width: 10),
          Container(
            width: 100,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / (total == 0 ? 1 : total),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}