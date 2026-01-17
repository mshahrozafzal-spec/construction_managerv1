// lib/features/holidays/holiday_dialog.dart
import 'package:flutter/material.dart';

class HolidayDialog extends StatefulWidget {
  final Map<String, dynamic>? holiday;
  final Function(Map<String, dynamic>) onSave;

  const HolidayDialog({
    Key? key,
    this.holiday,
    required this.onSave,
  }) : super(key: key);

  @override
  _HolidayDialogState createState() => _HolidayDialogState();
}

class _HolidayDialogState extends State<HolidayDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedType = 'general';
  bool _recurring = false;

  @override
  void initState() {
    super.initState();
    if (widget.holiday != null) {
      _nameController.text = widget.holiday!['name'] ?? '';
      _selectedDate = DateTime.parse(widget.holiday!['date']);
      _selectedType = widget.holiday!['type'] ?? 'general';
      _recurring = widget.holiday!['recurring'] == 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.holiday == null ? 'Add Holiday' : 'Edit Holiday'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Holiday Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter holiday name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _selectedDate != null
                      ? 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select Date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Holiday Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('General')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly (e.g., Sunday)')),
                  DropdownMenuItem(value: 'official', child: Text('Official')),
                  DropdownMenuItem(value: 'cultural', child: Text('Cultural')),
                  DropdownMenuItem(value: 'religious', child: Text('Religious')),
                ],
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Recurring Annually'),
                value: _recurring,
                onChanged: (value) {
                  setState(() => _recurring = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveHoliday,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveHoliday() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final holiday = {
        'name': _nameController.text,
        'date': _selectedDate!.toIso8601String(),
        'type': _selectedType,
        'recurring': _recurring ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      };
      widget.onSave(holiday);
    }
  }
}