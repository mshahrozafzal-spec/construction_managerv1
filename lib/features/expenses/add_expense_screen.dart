// lib/features/expenses/add_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/data/local/db_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  final int? projectId;

  const AddExpenseScreen({super.key, this.projectId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();

  // Controllers
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  // Variables
  String _category = 'Materials';
  DateTime? _expenseDate;
  List<Map<String, dynamic>> _projects = [];

  final List<String> _categoryOptions = [
    'Materials',
    'LaborModel',
    'Equipment',
    'Transport',
    'Rent',
    'Utilities',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _setDefaultValues();
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

  void _setDefaultValues() {
    _expenseDate = DateTime.now();
    _category = 'Materials';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add ExpenseModel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExpense,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ExpenseModel Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ExpenseModel Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (₹) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid positive amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category & Date
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category & Date',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categoryOptions.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _category = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _selectDate(context),
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
                                'ExpenseModel Date *',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _expenseDate == null
                                    ? 'Select Date'
                                    : _formatDate(_expenseDate!),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ProjectModel Selection (if not already set)
              if (widget.projectId == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ProjectModel (Optional)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int?>(
                          decoration: const InputDecoration(
                            labelText: 'Select ProjectModel',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.work),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('No ProjectModel (General ExpenseModel)'),
                            ),
                            ..._projects.map((ProjectModel) {
                              return DropdownMenuItem(
                                value: ProjectModel['id'] as int,
                                child: Text(ProjectModel['name'].toString()),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              // Store selected ProjectModel ID
                            });
                          },
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
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
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
                child: ElevatedButton.icon(
                  onPressed: _saveExpense,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save ExpenseModel',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _expenseDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_expenseDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select ExpenseModel date'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final ExpenseModel = {
        'project_id': widget.projectId,
        'category': _category,
        'description': _descriptionController.text,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'date': _expenseDate!.toIso8601String(),
        'notes': _notesController.text,
        // 'receipt_image': null, // You can add image upload later
      };

      try {
        await _dbHelper.insertExpense(ExpenseModel);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ExpenseModel saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving ExpenseModel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
