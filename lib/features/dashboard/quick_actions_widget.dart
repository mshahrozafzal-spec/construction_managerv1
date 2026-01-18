import 'package:flutter/material.dart';
import 'package:construction_manager/routes/app_routes.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.add,
                  label: 'Add Material',
                  route: AppRoutes.addMaterial,
                  color: Colors.blue,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.assignment,
                  label: 'Create Task',
                  route: AppRoutes.addTask,
                  color: Colors.green,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.person_add,
                  label: 'Add Labor',
                  route: AppRoutes.addLabor,
                  color: Colors.orange,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.receipt,
                  label: 'Record Expense',
                  route: AppRoutes.reports, // Changed to reports since we don't have addExpense screen yet
                  color: Colors.purple,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.work,
                  label: 'New Project',
                  route: AppRoutes.addProject,
                  color: Colors.teal,
                ),
                _buildActionButton(
                  context,
                  icon: Icons.report,
                  label: 'Generate Report',
                  route: AppRoutes.reports,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
        required Color color,
      }) {
    return SizedBox(
      width: 100,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
      ),
    );
  }
}