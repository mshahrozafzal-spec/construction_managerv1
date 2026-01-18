// lib/features/LaborModel/labor_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/data/local/db_helper.dart';
import 'package:construction_manager/features/Labor/add_labor_screen.dart';
class LaborScreen extends StatefulWidget {
  const LaborScreen({super.key});

  @override
  State<LaborScreen> createState() => _LaborScreenState();
}

class _LaborScreenState extends State<LaborScreen> {
  List<Map<String, dynamic>> _labors = [];
  List<Map<String, dynamic>> _filteredLabors = [];
  bool _isLoading = true;
  String _filterStatus = 'All';
  final List<String> _statusOptions = ['All', 'Active', 'Inactive', 'On Leave'];
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadLabors();
  }

  Future<void> _loadLabors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _labors = await _dbHelper.getAllLabor();
      _applyFilter();
    } catch (e) {
      print('Error loading labors: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_filterStatus == 'All') {
      _filteredLabors = _labors;
    } else {
      _filteredLabors = _labors.where((LaborModel) {
        final status = LaborModel['status']?.toString() ?? '';
        return status == _filterStatus;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LaborModel Management'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
                _applyFilter();
              });
            },
            itemBuilder: (context) => _statusOptions.map((status) {
              return PopupMenuItem<String>(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(status),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredLabors.isEmpty
          ? _buildEmptyState()
          : _buildLaborsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewLabor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No LaborModel registered',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first LaborModel',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _addNewLabor,
            child: const Text('Add LaborModel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLaborsList() {
    return RefreshIndicator(
      onRefresh: _loadLabors,
      child: ListView.builder(
        itemCount: _filteredLabors.length,
        itemBuilder: (context, index) {
          final LaborModel = _filteredLabors[index];
          return _buildLaborCard(LaborModel);
        },
      ),
    );
  }

  Widget _buildLaborCard(Map<String, dynamic> LaborModel) {
    final name = LaborModel['name'] ?? 'Unknown LaborModel';
    final role = LaborModel['role'] ?? 'Laborer';
    final status = LaborModel['status'] ?? 'Active';
    final phone = LaborModel['phone']?.toString() ?? '';
    final rate = (LaborModel['rate_per_hour'] as num?)?.toDouble() ?? 0.0;
    final laborId = LaborModel['id'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(role).withAlpha(25),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'L',
            style: TextStyle(
              color: _getRoleColor(role),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Role: $role'),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Phone: $phone'),
            ],
            if (rate > 0) ...[
              const SizedBox(height: 2),
              Text('Rate: \$${rate.toStringAsFixed(2)}/hr'),
            ],
          ],
        ),
        trailing: Chip(
          label: Text(status),
          backgroundColor: _getStatusColor(status).withAlpha(25),
          labelStyle: TextStyle(color: _getStatusColor(status)),
        ),
        onTap: () => _viewLaborDetails(LaborModel),
        onLongPress: () => _showLaborOptions(LaborModel),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'on leave':
        return Colors.orange;
      case 'probation':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'supervisor':
        return Colors.blue;
      case 'foreman':
        return Colors.purple;
      case 'engineer':
        return Colors.teal;
      case 'electrician':
        return Colors.orange;
      case 'plumber':
        return Colors.blue;
      case 'carpenter':
        return Colors.brown;
      case 'mason':
        return Colors.grey;
      case 'painter':
        return Colors.pink;
      case 'welder':
        return Colors.red;
      case 'operator':
        return Colors.indigo;
      default:
        return Colors.green;
    }
  }

  void _addNewLabor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddLaborScreen(),
      ),
    ).then((value) {
      if (value == true) {
        _loadLabors(); // Reload labors after adding
      }
    });
  }

  void _viewLaborDetails(Map<String, dynamic> LaborModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('LaborModel Details screen coming soon')),
    );
  }

  void _showLaborOptions(Map<String, dynamic> LaborModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit LaborModel'),
                onTap: () {
                  Navigator.pop(context);
                  _editLabor(LaborModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.green),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _viewLaborDetails(LaborModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_ind, color: Colors.orange),
                title: const Text('Assign to ProjectModel'),
                onTap: () {
                  Navigator.pop(context);
                  _assignToProject(LaborModel);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete LaborModel',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteLabor(LaborModel['id'] as int);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editLabor(Map<String, dynamic> LaborModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit LaborModel screen coming soon')),
    );
  }

  void _assignToProject(Map<String, dynamic> LaborModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assign to ProjectModel screen coming soon')),
    );
  }

  Future<void> _deleteLabor(int laborId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete LaborModel'),
        content: const Text('Are you sure you want to delete this LaborModel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteLabor(laborId);
        _loadLabors();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('LaborModel deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting LaborModel: $e')),
        );
      }
    }
  }
}
