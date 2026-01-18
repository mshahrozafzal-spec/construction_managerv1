import 'package:flutter/material.dart';

class QuickActionsManager {
  static List<Map<String, dynamic>> getQuickActions() {
    return [
      {
        'id': 'add_material',
        'title': 'Add Material',
        'description': 'Add new construction material to inventory',
        'icon': Icons.inventory,
        'color': Colors.blue,
        'route': '/materials/add',
      },
      {
        'id': 'create_task',
        'title': 'Create Task',
        'description': 'Create a new task for your project',
        'icon': Icons.assignment,
        'color': Colors.green,
        'route': '/tasks/add',
      },
      {
        'id': 'add_labor',
        'title': 'Add Labor',
        'description': 'Add new labor worker to workforce',
        'icon': Icons.person_add,
        'color': Colors.orange,
        'route': '/labor/add',
      },
      {
        'id': 'record_expense',
        'title': 'Record Expense',
        'description': 'Record project or material expense',
        'icon': Icons.receipt,
        'color': Colors.purple,
        'route': '/expenses/add',
      },
      {
        'id': 'new_project',
        'title': 'New Project',
        'description': 'Create a new construction project',
        'icon': Icons.work,
        'color': Colors.teal,
        'route': '/projects/add',
      },
      {
        'id': 'generate_report',
        'title': 'Generate Report',
        'description': 'Generate project or financial report',
        'icon': Icons.report,
        'color': Colors.red,
        'route': '/reports',
      },
      {
        'id': 'cost_control',
        'title': 'Cost Control',
        'description': 'Monitor and control material costs',
        'icon': Icons.analytics,
        'color': Colors.indigo,
        'route': '/materials/cost-control',
      },
      {
        'id': 'material_catalog',
        'title': 'Material Catalog',
        'description': 'Browse and manage materials',
        'icon': Icons.store,
        'color': Colors.blueGrey,
        'route': '/materials',
      },
    ];
  }

  static Widget buildActionIcon(Map<String, dynamic> action) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: action['color'].withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        action['icon'],
        color: action['color'],
        size: 24,
      ),
    );
  }

  static Widget buildActionCard(Map<String, dynamic> action, BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (action['route'] != null) {
            Navigator.pushNamed(context, action['route']);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              buildActionIcon(action),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action['description'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  static List<Widget> buildActionGrid(BuildContext context, {int maxItems = 6}) {
    final actions = getQuickActions().take(maxItems).toList();

    return actions.map((action) {
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            if (action['route'] != null) {
              Navigator.pushNamed(context, action['route']);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildActionIcon(action),
                const SizedBox(height: 12),
                Text(
                  action['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  action['description'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}