// lib/features/labor/labor_form_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/database/models/labor.dart';
import 'package:construction_manager/database/db_helper.dart';

class LaborFormScreen extends StatefulWidget {
  final Labor? labor;

  const LaborFormScreen({super.key, this.labor});

  @override
  State<LaborFormScreen> createState() => _LaborFormScreenState();
}

class _LaborFormScreenState extends State<LaborFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();

  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _skillsController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _dailyWageController = TextEditingController();
  final _monthlyWageController = TextEditingController();
  final _totalAdvanceController = TextEditingController();
  final _notesController = TextEditingController();

  String _role = 'Laborer';
  String _status = 'Active';
  String _paymentMethod = 'Cash';
  DateTime? _joinDate;
  int? _selectedProjectId;
  List<Map<String, dynamic>> _projects = [];

  final List<String> _roles = [
    'Laborer',
    'Supervisor',
    'Foreman',
    'Engineer',
    'Electrician',
    'Plumber',
    'Carpenter',
    'Mason',
    'Painter',
    'Welder',
    'Operator',
  ];

  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Check',
    'Digital Payment',
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
    if (widget.labor != null) {
      _loadExistingLabor();
    } else {
      _setDefaultValues();
    }
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _dbHelper.getProjects();
      setState(() {
        _projects = projects;
      });
    } catch (e) {
      print('Error loading projects: $e');
    }
  }

  void _loadExistingLabor() {
    final labor = widget.labor!;
    _nameController.text = labor.name;
    _contactController.text = labor.contact ?? '';
    _idNumberController.text = labor.idNumber ?? '';
    _addressController.text = labor.address ?? '';
    _skillsController.text = labor.skills ?? '';
    _emergencyContactController.text = labor.emergencyContact ?? '';
    _dailyWageController.text = labor.dailyWage.toString();
    _monthlyWageController.text = labor.monthlyWage.toString();
    _totalAdvanceController.text = labor.totalAdvance.toString();
    _notesController.text = labor.notes ?? '';
    _role = labor.role;
    _status = labor.status;
    _paymentMethod = labor.paymentMethod;
    _joinDate = labor.joinDate;
    _selectedProjectId = labor.projectId;
  }

  void _setDefaultValues() {
    _joinDate = DateTime.now();
    _status = 'Active';
    _role = 'Laborer';
    _paymentMethod = 'Cash';
    _dailyWageController.text = '500';
    _monthlyWageController.text = '15000';
    _totalAdvanceController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.labor == null ? 'Add Labor' : 'Edit Labor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveLabor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Personal Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _idNumberController,
                        decoration: const InputDecoration(
                          labelText: 'ID Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Job Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Job Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _role,
                              decoration: const InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(),
                              ),
                              items: _roles.map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _role = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: ['Active', 'Inactive', 'On Leave', 'Probation'].map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _status = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Financial Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Financial Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dailyWageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Daily Wage (₹)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _monthlyWageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Monthly Wage (₹)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _totalAdvanceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Total Advance (₹)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _paymentMethod,
                              decoration: const InputDecoration(
                                labelText: 'Payment Method',
                                border: OutlineInputBorder(),
                              ),
                              items: _paymentMethods.map((method) {
                                return DropdownMenuItem(
                                  value: method,
                                  child: Text(method),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _paymentMethod = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectJoinDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Join Date',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _joinDate == null
                                    ? 'Select Date'
                                    : _formatDate(_joinDate!),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _skillsController,
                        decoration: const InputDecoration(
                          labelText: 'Skills',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emergencyContactController,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Contact',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveLabor,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Labor',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectJoinDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joinDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _joinDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveLabor() async {
    if (_formKey.currentState!.validate()) {
      final labor = Labor(
        id: widget.labor?.id,
        name: _nameController.text,
        contact: _contactController.text.isNotEmpty ? _contactController.text : null,
        role: _role,
        dailyWage: double.tryParse(_dailyWageController.text) ?? 0.0,
        monthlyWage: double.tryParse(_monthlyWageController.text) ?? 0.0,
        paymentMethod: _paymentMethod,
        status: _status,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        totalAdvance: double.tryParse(_totalAdvanceController.text) ?? 0.0,
        idNumber: _idNumberController.text.isNotEmpty ? _idNumberController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        joinDate: _joinDate,
        skills: _skillsController.text.isNotEmpty ? _skillsController.text : null,
        emergencyContact: _emergencyContactController.text.isNotEmpty ? _emergencyContactController.text : null,
      );

      try {
        if (widget.labor == null) {
          await _dbHelper.insertLabor(labor.toMap());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Labor added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          if (labor.id != null) {
            await _dbHelper.updateLabor(labor.id!, labor.toMap());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Labor updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _idNumberController.dispose();
    _addressController.dispose();
    _skillsController.dispose();
    _emergencyContactController.dispose();
    _dailyWageController.dispose();
    _monthlyWageController.dispose();
    _totalAdvanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}