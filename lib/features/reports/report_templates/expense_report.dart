import 'package:flutter/material.dart';

class ExpenseReport extends StatelessWidget {
  final List<dynamic> expenses;
  final DateTime startDate;
  final DateTime endDate;
  final String reportTitle;

  const ExpenseReport({
    super.key,
    required this.expenses,
    required this.startDate,
    required this.endDate,
    this.reportTitle = 'Expense Report',
  });

  @override
  Widget build(BuildContext context) {
    final totalExpenses = expenses.fold(0.0, (sum, expense) => sum + (expense['amount'] ?? 0));
    final categoryTotals = _calculateCategoryTotals();

    return Scaffold(
      appBar: AppBar(
        title: Text(reportTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReport(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Header
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reportTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Period: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Generated on: ${_formatDate(DateTime.now())}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Expenses',
                            '₹${totalExpenses.toStringAsFixed(2)}',
                            Colors.red,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            'Number of Expenses',
                            expenses.length.toString(),
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            'Categories',
                            categoryTotals.length.toString(),
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Breakdown
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...categoryTotals.entries.map((entry) {
                      final percentage = totalExpenses > 0 ? (entry.value / totalExpenses * 100) : 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(entry.key),
                                ),
                                Text(
                                  '₹${entry.value.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCategoryColor(entry.key),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${percentage.toStringAsFixed(1)}% of total',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Detailed Expenses
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detailed Expenses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...expenses.map((expense) {
                      return ListTile(
                        leading: const Icon(Icons.receipt, color: Colors.blue),
                        title: Text(expense['description'] ?? 'No Description'),
                        subtitle: Text(
                          '${expense['category'] ?? 'Uncategorized'} • ${_formatDate(expense['date'])}',
                        ),
                        trailing: Text(
                          '₹${(expense['amount'] ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Export Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _exportReport(context),
                icon: const Icon(Icons.download),
                label: const Text('Export as PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Map<String, double> _calculateCategoryTotals() {
    final Map<String, double> totals = {};
    for (var expense in expenses) {
      final category = expense['category'] ?? 'Uncategorized';
      final amount = expense['amount'] ?? 0.0;
      totals[category] = (totals[category] ?? 0) + amount;
    }
    return totals;
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.brown,
    ];
    final index = category.hashCode % colors.length;
    return colors[index];
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    if (date is String) {
      try {
        final parsed = DateTime.parse(date);
        return '${parsed.day}/${parsed.month}/${parsed.year}';
      } catch (e) {
        return date;
      }
    }
    return date.toString();
  }

  void _printReport(BuildContext context) {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon')),
    );
  }

  void _shareReport(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _exportReport(BuildContext context) {
    // TODO: Implement PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export coming soon')),
    );
  }
}