import 'package:flutter/material.dart';

class LaborFormScreen extends StatefulWidget {
  final dynamic labor;

  const LaborFormScreen({super.key, this.labor});

  @override
  State<LaborFormScreen> createState() => _LaborFormScreenState();
}

class _LaborFormScreenState extends State<LaborFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _skillController = TextEditingController();
  final _dailyWageController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedSkill = 'General Labor';
  String _selectedStatus = 'Active';

  final List<String> _skills = [
    'General Labor',
    'Mason',
    'Carpenter',
    'Electrician',
    'Plumber',
    'Welder',
    'Painter',
    'Foreman',
    'Operator',
    'Supervisor',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.labor != null) {
      _loadExistingLabor();
    }
  }

  void _loadExistingLabor() {
    // Assuming labor object has these properties
    _nameController.text = widget.labor['name'] ?? '';
    _phoneController.text = widget.labor['phone'] ?? '';
    _emailController.text = widget.labor['email'] ?? '';
    _addressController.text = widget.labor['address'] ?? '';
    _skillController.text = widget.labor['skill'] ?? '';
    _dailyWageController.text = widget.labor['dailyWage']?.toString() ?? '';
    _notesController.text = widget.labor['notes'] ?? '';
    _selectedSkill = widget.labor['skill'] ?? 'General Labor';
    _selectedStatus = widget.labor['status'] ?? 'Active';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Labor Name *',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Labor name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          if (value.length < 10) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skills & Wage Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Skills & Wage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSkill,
                        decoration: InputDecoration(
                          labelText: 'Skill/Position *',
                          prefixIcon: const Icon(Icons.work),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _skills.map((skill) {
                          return DropdownMenuItem(
                            value: skill,
                            child: Text(skill),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSkill = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dailyWageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Daily Wage (₹) *',
                                prefixIcon: const Icon(Icons.currency_rupee),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Daily wage is required';
                                }
                                final wage = double.tryParse(value);
                                if (wage == null || wage <= 0) {
                                  return 'Enter a valid wage amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: InputDecoration(
                                labelText: 'Status *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: ['Active', 'Inactive', 'On Leave']
                                  .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedStatus = value;
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

              // Address & Notes Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address & Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.home),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: const Icon(Icons.note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                child: ElevatedButton(
                  onPressed: _saveLabor,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

  Future<void> _saveLabor() async {
    if (_formKey.currentState!.validate()) {
      try {
        final labor = {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'skill': _selectedSkill,
          'dailyWage': double.tryParse(_dailyWageController.text) ?? 0.0,
          'status': _selectedStatus,
          'notes': _notesController.text,
        };

        // TODO: Save labor to database
        print('Saving labor: $labor');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Labor saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _skillController.dispose();
    _dailyWageController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}