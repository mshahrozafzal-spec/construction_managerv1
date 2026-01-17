// lib/features/dashboard/quick_actions_widget.dart
import 'package:flutter/material.dart';

// Simple quick actions widget without complex configuration
class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<QuickAction> actions = [
      QuickAction(
        title: 'New Project',
        icon: Icons.add_circle,
        color: Colors.blue,
        onTap: () {
          // Navigate to new project
        },
      ),
      QuickAction(
        title: 'New Task',
        icon: Icons.task,
        color: Colors.green,
        onTap: () {
          // Navigate to new task
        },
      ),
      QuickAction(
        title: 'Add Labor',
        icon: Icons.person_add,
        color: Colors.orange,
        onTap: () {
          // Navigate to add labor
        },
      ),
      QuickAction(
        title: 'Add Expense',
        icon: Icons.attach_money,
        color: Colors.purple,
        onTap: () {
          // Navigate to add expense
        },
      ),
      QuickAction(
        title: 'Reports',
        icon: Icons.analytics,
        color: Colors.teal,
        onTap: () {
          // Navigate to reports
        },
      ),
      QuickAction(
        title: 'Calendar',
        icon: Icons.calendar_month,
        color: Colors.red,
        onTap: () {
          // Navigate to calendar
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _buildQuickActionItem(actions[index], context);
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(QuickAction action, BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: action.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color, size: 30),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                action.title,
                style: TextStyle(
                  color: action.color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}