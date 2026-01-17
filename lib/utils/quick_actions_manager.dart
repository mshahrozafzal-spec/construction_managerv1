// lib/utils/quick_actions_manager.dart
import 'package:flutter/material.dart';
// Remove shared_preferences for now to simplify

class QuickActionsManager {
  // Simple implementation without persistence
  static List<QuickActionConfig> getDefaultActions() {
    return [
      QuickActionConfig(
        id: 'new_project',
        title: 'New Project',
        icon: Icons.add_circle,
        color: Colors.blue,
        enabledByDefault: true,
      ),
      QuickActionConfig(
        id: 'new_task',
        title: 'New Task',
        icon: Icons.task,
        color: Colors.green,
        enabledByDefault: true,
      ),
      QuickActionConfig(
        id: 'add_labor',
        title: 'Add Labor',
        icon: Icons.person_add,
        color: Colors.orange,
        enabledByDefault: true,
      ),
      QuickActionConfig(
        id: 'add_expense',
        title: 'Add Expense',
        icon: Icons.attach_money,
        color: Colors.purple,
        enabledByDefault: true,
      ),
      QuickActionConfig(
        id: 'reports',
        title: 'Reports',
        icon: Icons.analytics,
        color: Colors.teal,
        enabledByDefault: false,
      ),
      QuickActionConfig(
        id: 'calendar',
        title: 'Calendar',
        icon: Icons.calendar_month,
        color: Colors.red,
        enabledByDefault: false,
      ),
      QuickActionConfig(
        id: 'materials',
        title: 'Materials',
        icon: Icons.inventory,
        color: Colors.brown,
        enabledByDefault: false,
      ),
      QuickActionConfig(
        id: 'time_tracking',
        title: 'Time Track',
        icon: Icons.timer,
        color: Colors.indigo,
        enabledByDefault: false,
      ),
    ];
  }
}

class QuickActionConfig {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final bool enabledByDefault;

  QuickActionConfig({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.enabledByDefault,
  });
}