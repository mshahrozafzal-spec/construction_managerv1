// lib/features/expenses/expenses_screen.dart
import 'package:flutter/material.dart';
import 'package:construction_manager/features/expenses/add_expense_screen.dart';
import 'package:construction_manager/data/local/db_helper.dart';

class ExpensesScreen extends StatefulWidget {
  final int? projectId;

  const ExpensesScreen({super.key, this.projectId});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;
  double _totalExpenses = 0;
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.projectId != null) {
        // Get expenses for specific ProjectModel
        _expenses = await _dbHelper.getExpensesByProject(widget.projectId!);
      } else {
        // Get all expenses
        _expenses = await _dbHelper.getAllExpenses();
      }

      // Calculate total - FIXED
      _totalExpenses = 0.0;
      for (var ExpenseModel in _expenses) {
        final amount = ExpenseModel['amount'];
        if (amount != null) {
          // Convert to double safely
          if (amount is int) {
            _totalExpenses += amount.toDouble();
          } else if (amount is double) {
            _totalExpenses += amount;
          } else if (amount is String) {
            _totalExpenses += double.tryParse(amount) ?? 0.0;
          }
        }
      }
    } catch (e) {
      print('Error loading expenses: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.projectId != null
            ? const Text('ProjectModel Expenses')
            : const Text('All Expenses'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
          ? _buildEmptyState()
          : _buildExpensesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(projectId: widget.projectId),
            ),
          ).then((value) {
            if (value == true) {
              _loadExpenses();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.money_off, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No expenses yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first ExpenseModel',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExpenseScreen(projectId: widget.projectId),
                ),
              ).then((value) {
                if (value == true) {
                  _loadExpenses();
                }
              });
            },
            child: const Text('Add ExpenseModel'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    return Column(
      children: [
        // Total expenses card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Total Expenses',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expenses list
        Expanded(
          child: ListView.builder(
            itemCount: _expenses.length,
            itemBuilder: (context, index) {
              final ExpenseModel = _expenses[index];
              return _buildExpenseCard(ExpenseModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> ExpenseModel) {
    final description = ExpenseModel['description'] ?? 'No description';
    final category = ExpenseModel['category'] ?? 'Uncategorized';
    final amount = ExpenseModel['amount'];
    final date = ExpenseModel['date']?.toString() ?? '';
    final notes = ExpenseModel['notes']?.toString() ?? '';

    // Safely convert amount to double
    double amountValue = 0.0;
    if (amount != null) {
      if (amount is int) {
        amountValue = amount.toDouble();
      } else if (amount is double) {
        amountValue = amount;
      } else if (amount is String) {
        amountValue = double.tryParse(amount) ?? 0.0;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(category).withAlpha(25),
          child: Icon(
            _getCategoryIcon(category),
            color: _getCategoryColor(category),
          ),
        ),
        title: Text(description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Category: $category'),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Notes: $notes'),
            ],
            if (date.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Date: ${_formatDate(date)}'),
            ],
          ],
        ),
        trailing: Text(
          '₹${amountValue.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        onTap: () => _viewExpenseDetails(ExpenseModel),
        onLongPress: () => _showExpenseOptions(ExpenseModel),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'materials':
        return Colors.blue;
      case 'LaborModel':
        return Colors.green;
      case 'equipment':
        return Colors.orange;
      case 'transport':
        return Colors.purple;
      case 'rent':
        return Colors.brown;
      case 'utilities':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'materials':
        return Icons.build;
      case 'LaborModel':
        return Icons.people;
      case 'equipment':
        return Icons.settings;
      case 'transport':
        return Icons.local_shipping;
      case 'rent':
        return Icons.home;
      case 'utilities':
        return Icons.bolt;
      default:
        return Icons.money;
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

  void _viewExpenseDetails(Map<String, dynamic> ExpenseModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ExpenseModel Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${ExpenseModel['description'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Category: ${ExpenseModel['category'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Amount: ₹${(ExpenseModel['amount'] ?? 0).toString()}'),
            const SizedBox(height: 8),
            if (ExpenseModel['date'] != null)
              Text('Date: ${_formatDate(ExpenseModel['date'].toString())}'),
            const SizedBox(height: 8),
            if (ExpenseModel['notes'] != null && ExpenseModel['notes'].toString().isNotEmpty)
              Text('Notes: ${ExpenseModel['notes']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExpenseOptions(Map<String, dynamic> ExpenseModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _viewExpenseDetails(ExpenseModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text('Edit ExpenseModel'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit ExpenseModel
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit feature coming soon')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete ExpenseModel',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteExpense(ExpenseModel['id'] as int);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteExpense(int expenseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete ExpenseModel'),
        content: const Text('Are you sure you want to delete this ExpenseModel?'),
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
        await _dbHelper.deleteExpense(expenseId);
        _loadExpenses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ExpenseModel deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting ExpenseModel: $e')),
        );
      }
    }
  }
}
