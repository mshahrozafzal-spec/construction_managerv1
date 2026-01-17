// lib/features/holidays/holidays_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_manager/database/db_helper.dart';
import 'package:construction_manager/features/holidays/holiday_dialog.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({Key? key}) : super(key: key);

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  List<Map<String, dynamic>> _holidays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
    final dbHelper = DBHelper();
    final holidays = await dbHelper.getHolidays();
    setState(() {
      _holidays = holidays;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Holidays'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addHoliday(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildHolidaysList(),
    );
  }

  Widget _buildHolidaysList() {
    if (_holidays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'No Holidays Added',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add holidays to exclude them from working days',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _addHoliday(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Holiday'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _holidays.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return _buildHolidayCard(_holidays[index]);
      },
    );
  }

  Widget _buildHolidayCard(Map<String, dynamic> holiday) {
    final name = holiday['name'] ?? 'Unnamed Holiday';
    final date = DateTime.parse(holiday['date'] as String);
    final type = holiday['type'] ?? 'general';
    final recurring = holiday['recurring'] == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getHolidayColor(type).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getHolidayIcon(type),
            color: _getHolidayColor(type),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day}/${date.month}/${date.year} (${_getWeekday(date.weekday)})',
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Chip(
                  label: Text(
                    type.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getHolidayColor(type).withOpacity(0.2),
                ),
                if (recurring) ...[
                  const SizedBox(width: 4),
                  const Chip(
                    label: Text(
                      'RECURRING',
                      style: TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.green,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteHoliday(holiday['id'] as int, name),
        ),
        onTap: () => _editHoliday(holiday),
      ),
    );
  }

  Color _getHolidayColor(String type) {
    switch (type.toLowerCase()) {
      case 'weekly':
        return Colors.blue;
      case 'cultural':
        return Colors.purple;
      case 'official':
        return Colors.red;
      case 'religious':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getHolidayIcon(String type) {
    switch (type.toLowerCase()) {
      case 'weekly':
        return Icons.weekend;
      case 'cultural':
        return Icons.celebration;
      case 'official':
        return Icons.business;
      case 'religious':
        return Icons.church;
      default:
        return Icons.event;
    }
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  void _addHoliday(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => HolidayDialog(
        onSave: (holiday) async {
          final dbHelper = DBHelper();
          await dbHelper.insertHoliday(holiday);
          _loadHolidays();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editHoliday(Map<String, dynamic> holiday) {
    showDialog(
      context: context,
      builder: (context) => HolidayDialog(
        holiday: holiday,
        onSave: (updatedHoliday) async {
          final dbHelper = DBHelper();
          await dbHelper.updateHoliday(holiday['id'] as int, updatedHoliday);
          _loadHolidays();
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _deleteHoliday(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Holiday'),
        content: Text('Are you sure you want to delete "$name"?'),
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
      final dbHelper = DBHelper();
      await dbHelper.deleteHoliday(id);
      _loadHolidays();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Holiday deleted')),
      );
    }
  }
}