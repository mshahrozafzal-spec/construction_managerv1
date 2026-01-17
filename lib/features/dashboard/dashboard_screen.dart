// lib/features/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/features/projects/projects_screen.dart';
import 'package:construction_manager/features/tasks/tasks_screen.dart';
import 'package:construction_manager/features/labor/labor_screen.dart';
import 'package:construction_manager/features/projects/project_form_screen.dart';
import 'package:construction_manager/features/tasks/add_task_screen.dart';
import 'package:construction_manager/features/labor/add_labor_screen.dart';
import 'package:construction_manager/features/expenses/expenses_screen.dart';
// ADD THESE TWO LINES FOR MATERIAL MANAGEMENT:
import 'package:construction_manager/features/materials/screens/material_catalog_screen.dart';
import 'package:construction_manager/features/materials/screens/cost_control_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _dbHelper.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                title: 'Active Projects',
                value: '${_stats['activeProjects'] ?? 0}',
                icon: Icons.construction,
                color: Colors.blue,
                subtitle: 'Currently running',
                onTap: () => _navigateToProjects(),
              ),
              _buildStatCard(
                title: 'Total Projects',
                value: '${_stats['totalProjects'] ?? 0}',
                icon: Icons.folder,
                color: Colors.green,
                subtitle: 'All projects',
                onTap: () => _navigateToProjects(),
              ),
              _buildStatCard(
                title: 'Pending Tasks',
                value: '${_stats['pendingTasks'] ?? 0}',
                icon: Icons.pending_actions,
                color: Colors.orange,
                subtitle: 'Awaiting completion',
                onTap: () => _navigateToTasks(),
              ),
              _buildStatCard(
                title: 'Completed Tasks',
                value: '${_stats['completedTasks'] ?? 0}',
                icon: Icons.task_alt,
                color: Colors.teal,
                subtitle: 'Finished tasks',
                onTap: () => _navigateToTasks(),
              ),
              _buildStatCard(
                title: 'Total Labor',
                value: '${_stats['totalLabor'] ?? 0}',
                icon: Icons.people,
                color: Colors.purple,
                subtitle: 'Workforce',
                onTap: () => _navigateToLabor(),
              ),
              _buildStatCard(
                title: 'Upcoming',
                value: '${_stats['upcomingDeadlines'] ?? 0}',
                icon: Icons.calendar_today,
                color: Colors.red,
                subtitle: 'Deadlines this week',
                onTap: () => _navigateToTasks(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions Section - UPDATED WITH MATERIAL MANAGEMENT
          _buildQuickActions(),

          const SizedBox(height: 24),

          // Recent Activity Section
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: [
            _buildQuickActionItem(
              title: 'New Project',
              icon: Icons.add_circle,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProjectFormScreen(),
                  ),
                );
              },
            ),
            _buildQuickActionItem(
              title: 'New Task',
              icon: Icons.task,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTaskScreen(),
                  ),
                );
              },
            ),
            _buildQuickActionItem(
              title: 'Add Labor',
              icon: Icons.person_add,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddLaborScreen(),
                  ),
                );
              },
            ),
            _buildQuickActionItem(
              title: 'Add Expense',
              icon: Icons.attach_money,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpensesScreen(),
                  ),
                );
              },
            ),
            // ADDED MATERIAL CATALOG
            _buildQuickActionItem(
              title: 'Material Catalog',
              icon: Icons.inventory,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaterialCatalogScreen(),
                  ),
                );
              },
            ),
            // ADDED COST CONTROL
            _buildQuickActionItem(
              title: 'Cost Control',
              icon: Icons.analytics,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CostControlScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(100)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                style: TextStyle(
                  color: color,
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

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                  title: const Text('New project created'),
                  subtitle: const Text('Just now'),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                  title: const Text('Task completed'),
                  subtitle: const Text('2 hours ago'),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  title: const Text('New labor added'),
                  subtitle: const Text('Today, 10:30 AM'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToProjects() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProjectsScreen()),
    );
  }

  void _navigateToTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TasksScreen()),
    );
  }

  void _navigateToLabor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LaborScreen()),
    );
  }
}