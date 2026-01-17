// lib/features/dashboard/stat_cards.dart
import 'package:flutter/material.dart';

class DashboardStatCards extends StatelessWidget {
  final Map<String, dynamic> stats;

  const DashboardStatCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      children: [
        _buildStatCard(
          'Total Projects',
          stats['totalProjects'].toString(),
          Icons.assignment,
          Colors.blue,
        ),
        _buildStatCard(
          'Active Projects',
          stats['activeProjects'].toString(),
          Icons.rocket_launch,
          Colors.green,
        ),
        _buildStatCard(
          'Total Tasks',
          stats['totalTasks'].toString(),
          Icons.task,
          Colors.orange,
        ),
        _buildStatCard(
          'Completion Rate',
          '${stats['completionRate']}%',
          Icons.timeline,
          Colors.purple,
        ),
        _buildStatCard(
          'Total Labor',
          stats['totalLabor'].toString(),
          Icons.people,
          Colors.teal,
        ),
        _buildStatCard(
          'Budget Spent',
          '₹${stats['totalSpent']?.toStringAsFixed(0) ?? '0'}',
          Icons.attach_money,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (title == 'Completion Rate')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCompletionColor(int.parse(value.replaceAll('%', ''))),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title == 'Budget Spent' || title == 'Budget Remaining'
                  ? value
                  : value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCompletionColor(int percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.blue;
    if (percentage >= 25) return Colors.orange;
    return Colors.red;
  }
}