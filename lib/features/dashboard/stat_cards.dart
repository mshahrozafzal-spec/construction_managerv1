import 'package:flutter/material.dart';

class StatCards extends StatelessWidget {
  final int totalProjects;
  final int activeTasks;
  final int totalLabor;
  final double totalExpenses;

  const StatCards({
    super.key,
    required this.totalProjects,
    required this.activeTasks,
    required this.totalLabor,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'Total Projects',
          value: totalProjects.toString(),
          icon: Icons.work,
          color: Colors.blue,
          subtitle: 'Active projects',
        ),
        _buildStatCard(
          title: 'Active Tasks',
          value: activeTasks.toString(),
          icon: Icons.assignment,
          color: Colors.green,
          subtitle: 'In progress',
        ),
        _buildStatCard(
          title: 'Total Labor',
          value: totalLabor.toString(),
          icon: Icons.people,
          color: Colors.orange,
          subtitle: 'Workforce',
        ),
        _buildStatCard(
          title: 'Total Expenses',
          value: '₹${totalExpenses.toStringAsFixed(2)}',
          icon: Icons.currency_rupee,
          color: Colors.purple,
          subtitle: 'This month',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}