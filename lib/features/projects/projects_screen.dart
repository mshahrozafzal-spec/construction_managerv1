// lib/features/projects/projects_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/data/local/db_helper.dart';
import 'package:construction_manager/features/projects/add_project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final projects = await _dbHelper.getProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading projects: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewProject,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
          ? _buildEmptyState()
          : _buildProjectsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProject,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No Projects Yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create your first ProjectModel to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _addNewProject,
            icon: const Icon(Icons.add),
            label: const Text('Create ProjectModel'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: ListView.builder(
        itemCount: _projects.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final ProjectModel = _projects[index];
          return _buildProjectCard(ProjectModel);
        },
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> ProjectModel) {
    final projectName = ProjectModel['name'] ?? 'Unnamed ProjectModel';
    final status = ProjectModel['status'] ?? 'active';
    final startDate = ProjectModel['start_date'] ?? '';
    final endDate = ProjectModel['end_date'] ?? '';
    final projectId = ProjectModel['id'] as int? ?? 0;
    final budget = ProjectModel['budget'] as double? ?? 0.0;
    final clientName = ProjectModel['client_name'] ?? '';

    return Dismissible(
      key: Key('project_$projectId'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(ProjectModel);
        }
        return false;
      },
      onDismissed: (direction) {
        _deleteProject(projectId);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getStatusColor(status).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.construction,
              color: _getStatusColor(status),
              size: 30,
            ),
          ),
          title: Text(
            projectName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Status: ${status.toUpperCase()}',
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (startDate.isNotEmpty && endDate.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Duration: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              if (clientName.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Client: $clientName',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              if (budget > 0) ...[
                const SizedBox(height: 2),
                Text(
                  'Budget: \$${budget.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _handlePopupSelection(value, ProjectModel),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Archive'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _viewProjectDetails(ProjectModel),
          onLongPress: () => _showProjectOptions(ProjectModel),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(Map<String, dynamic> ProjectModel) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete ProjectModel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${ProjectModel['name']}"?'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Warning: This action will also delete:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 8),
            const Text('• All associated tasks'),
            const Text('• All related expenses'),
            const Text('• All work logs'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Anyway'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showProjectOptions(Map<String, dynamic> ProjectModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit ProjectModel'),
                onTap: () {
                  Navigator.pop(context);
                  _editProject(ProjectModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.green),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _viewProjectDetails(ProjectModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.orange),
                title: const Text('Duplicate ProjectModel'),
                onTap: () {
                  Navigator.pop(context);
                  _duplicateProject(ProjectModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive, color: Colors.grey),
                title: const Text('Archive ProjectModel'),
                onTap: () {
                  Navigator.pop(context);
                  _archiveProject(ProjectModel['id'] as int);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete ProjectModel',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await _showDeleteConfirmation(ProjectModel);
                  if (confirmed) {
                    _deleteProject(ProjectModel['id'] as int);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'on hold':
        return Colors.yellow;
      case 'archived':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _handlePopupSelection(String value, Map<String, dynamic> ProjectModel) {
    switch (value) {
      case 'edit':
        _editProject(ProjectModel);
        break;
      case 'view':
        _viewProjectDetails(ProjectModel);
        break;
      case 'duplicate':
        _duplicateProject(ProjectModel);
        break;
      case 'archive':
        _archiveProject(ProjectModel['id'] as int);
        break;
      case 'delete':
        _showDeleteConfirmation(ProjectModel).then((confirmed) {
          if (confirmed) {
            _deleteProject(ProjectModel['id'] as int);
          }
        });
        break;
    }
  }

  void _addNewProject() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProjectScreen(),
      ),
    ).then((value) {
      if (value == true) {
        _loadProjects(); // Reload projects after adding
      }
    });
  }

  void _editProject(Map<String, dynamic> ProjectModel) {
    // Navigate to edit ProjectModel screen
    // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProjectScreen(ProjectModel: ProjectModel)))
    //     .then((_) => _loadProjects());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit ProjectModel screen coming soon')),
    );
  }

  void _viewProjectDetails(Map<String, dynamic> ProjectModel) {
    // Navigate to ProjectModel details screen
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectDetailsScreen(ProjectModel: ProjectModel)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ProjectModel Details screen coming soon')),
    );
  }

  Future<void> _deleteProject(int id) async {
    try {
      await _dbHelper.deleteProject(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ProjectModel deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.white,
            onPressed: () {
              // Could implement undo functionality here
              _loadProjects();
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      _loadProjects();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting ProjectModel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _archiveProject(int id) async {
    try {
      await _dbHelper.updateProject(id, {'status': 'archived'});
      _loadProjects();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ProjectModel archived')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error archiving ProjectModel: $e')),
      );
    }
  }

  Future<void> _duplicateProject(Map<String, dynamic> ProjectModel) async {
    try {
      final newProject = Map<String, dynamic>.from(ProjectModel);
      newProject.remove('id');
      newProject['name'] = '${ProjectModel['name']} (Copy)';
      newProject['created_at'] = DateTime.now().toIso8601String();

      await _dbHelper.insertProject(newProject);
      _loadProjects();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ProjectModel duplicated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error duplicating ProjectModel: $e')),
      );
    }
  }
}
