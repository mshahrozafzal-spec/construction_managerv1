import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_manager/state/material_provider.dart';
import 'package:construction_manager/data/models/material_model.dart';

class CostControlScreen extends StatefulWidget {
  const CostControlScreen({super.key});

  @override
  State<CostControlScreen> createState() => _CostControlScreenState();
}

class _CostControlScreenState extends State<CostControlScreen> {
  Map<String, dynamic>? _materialStats;
  Map<String, double>? _categoryValues;
  double _totalInventoryValue = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    Future.microtask(() {
      _loadCostData();
    });
  }

  Future<void> _loadCostData() async {
    final provider = Provider.of<MaterialProvider>(context, listen: false);

    try {
      // Load multiple data sources in parallel
      final results = await Future.wait([
        provider.getMaterialStatsAsync(),
        provider.getCategoryWiseInventoryValueAsync(),
        provider.getTotalInventoryValueAsync(),
      ]);

      setState(() {
        _materialStats = results[0] as Map<String, dynamic>;
        _categoryValues = results[1] as Map<String, double>;
        _totalInventoryValue = results[2] as double;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cost data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Control & Budgeting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCostData,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: Consumer<MaterialProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && _materialStats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      _loadCostData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.materials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.analytics, size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'No Materials',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add materials to see cost control analytics',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadCostData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummaryCards(provider),

                  const SizedBox(height: 24),

                  // Category Spending
                  _buildCategorySpending(),

                  const SizedBox(height: 24),

                  // Low Stock Alerts
                  _buildLowStockAlerts(provider),

                  const SizedBox(height: 24),

                  // Inventory Overview
                  _buildInventoryOverview(provider),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(MaterialProvider provider) {
    final totalMaterials = _materialStats?['total_materials'] ?? 0;
    final lowStockCount = _materialStats?['low_stock'] ?? 0;
    final outOfStockCount = _materialStats?['out_of_stock'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildCostCard(
          title: 'Total Inventory Value',
          value: '₹${_totalInventoryValue.toStringAsFixed(2)}',
          icon: Icons.warehouse,
          color: Colors.blue,
          subtitle: 'Current stock value',
        ),
        _buildCostCard(
          title: 'Total Materials',
          value: totalMaterials.toString(),
          icon: Icons.inventory,
          color: Colors.green,
          subtitle: 'Material types',
        ),
        _buildCostCard(
          title: 'Low Stock',
          value: lowStockCount.toString(),
          icon: Icons.warning,
          color: Colors.orange,
          subtitle: 'Needs attention',
        ),
        _buildCostCard(
          title: 'Out of Stock',
          value: outOfStockCount.toString(),
          icon: Icons.error,
          color: Colors.red,
          subtitle: 'Zero stock items',
        ),
      ],
    );
  }

  Widget _buildCostCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpending() {
    if (_categoryValues == null || _categoryValues!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category-wise Spending',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('No category data available'),
              ),
            ],
          ),
        ),
      );
    }

    final entries = _categoryValues!.entries.toList();
    final total = entries.fold(0.0, (sum, entry) => sum + entry.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category-wise Spending',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('₹${total.toStringAsFixed(2)}'),
                  backgroundColor: Colors.blue.withAlpha(25),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...entries.map((entry) {
              final percentage = total > 0 ? (entry.value / total * 100) : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 14),
                          ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}% of total',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${(entry.value / _totalInventoryValue * 100).toStringAsFixed(1)}% of inventory',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlerts(MaterialProvider provider) {
    final lowStockMaterials = provider.lowStockMaterials;

    if (lowStockMaterials.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stock Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'All materials are well stocked',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate total value of low stock items
    final lowStockValue = lowStockMaterials.fold(
      0.0,
          (sum, material) => sum + material.totalValue,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${lowStockMaterials.length} items'),
                  backgroundColor: Colors.orange.withAlpha(25),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total value at risk: ₹${lowStockValue.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            ...lowStockMaterials.map((material) {
              final requiredStock = (material.minStockLevel ?? 0) - material.currentStock;
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(material.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current: ${material.currentStock} ${material.unit}'),
                    Text('Required: +${requiredStock.toStringAsFixed(1)} ${material.unit}'),
                    if (material.unitPrice != null)
                      Text('Cost: ₹${(requiredStock * material.unitPrice!).toStringAsFixed(2)}'),
                  ],
                ),
                trailing: TextButton(
                  onPressed: () => _reorderMaterial(material),
                  child: const Text('Order'),
                ),
              );
            }).toList(),
            if (lowStockMaterials.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _bulkReorder(lowStockMaterials),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Order All Low Stock Items'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryOverview(MaterialProvider provider) {
    final highValueMaterials = provider.materials
        .where((m) => m.totalValue > 10000) // Materials worth more than ₹10,000
        .toList()
        .take(5); // Show top 5

    if (highValueMaterials.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'High Value Materials',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Materials with highest inventory value',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ...highValueMaterials.map((material) {
              final percentage = (_totalInventoryValue > 0)
                  ? (material.totalValue / _totalInventoryValue * 100)
                  : 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(material.name),
                          Text(
                            '${material.currentStock} ${material.unit}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${material.totalValue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.amber,
      Colors.brown,
      Colors.pink,
      Colors.indigo,
    ];
    final index = category.hashCode % colors.length;
    return colors[index];
  }

  void _exportReport() async {
    final provider = Provider.of<MaterialProvider>(context, listen: false);

    try {
      final report = await provider.generateInventoryReportAsync();

      // Show report preview
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Inventory Report'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: report.length,
              itemBuilder: (context, index) {
                final item = report[index];
                return ListTile(
                  title: Text(item['name'] as String),
                  subtitle: Text('${item['category']} - Stock: ${item['stock']} ${item['unit']}'),
                  trailing: Text('₹${(item['total_value'] as double).toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement export
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export feature coming soon')),
                );
                Navigator.pop(context);
              },
              child: const Text('Export'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: $e')),
      );
    }
  }

  void _reorderMaterial(MaterialModel material) {
    // TODO: Navigate to order screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ordering ${material.name}...'),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
        ),
      ),
    );
  }

  void _bulkReorder(List<MaterialModel> materials) {
    // TODO: Implement bulk ordering
    final totalCost = materials.fold(0.0, (sum, material) {
      final required = (material.minStockLevel ?? 0) - material.currentStock;
      return sum + (required * (material.unitPrice ?? 0));
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Order'),
        content: Text(
          'Order ${materials.length} items\n'
              'Estimated cost: ₹${totalCost.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Process bulk order
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bulk order feature coming soon')),
              );
              Navigator.pop(context);
            },
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }
}