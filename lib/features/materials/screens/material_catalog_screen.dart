import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_manager/state/material_provider.dart';
import 'package:construction_manager/data/models/material_model.dart';
import 'package:construction_manager/features/materials/screens/add_material_screen.dart';

class MaterialCatalogScreen extends StatefulWidget {
  const MaterialCatalogScreen({super.key});

  @override
  State<MaterialCatalogScreen> createState() => _MaterialCatalogScreenState();
}

class _MaterialCatalogScreenState extends State<MaterialCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MaterialProvider>(context, listen: false).loadMaterials();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<MaterialProvider>(context, listen: false).loadMaterials();
            },
          ),
        ],
      ),
      body: Consumer<MaterialProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.materials.isEmpty) {
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
                    onPressed: () => provider.loadMaterials(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final materials = provider.filteredMaterials;

          return Column(
            children: [
              // Search and Filter Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search materials...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                        )
                            : null,
                      ),
                      onChanged: (value) {
                        provider.setSearchQuery(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip('All', provider),
                          ...provider.categories.map((category) =>
                              _buildCategoryChip(category.name, provider)).toList(),
                          if (provider.materials.any((m) => m.categoryId == null))
                            _buildCategoryChip('Uncategorized', provider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Items',
                        value: provider.materials.length.toString(),
                        icon: Icons.inventory,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Low Stock',
                        value: provider.lowStockMaterials.length.toString(),
                        icon: Icons.warning,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Value',
                        value: '₹${provider.totalInventoryValue.toStringAsFixed(2)}',
                        icon: Icons.currency_rupee,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Materials List
              Expanded(
                child: materials.isEmpty
                    ? _buildEmptyState(provider)
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    return _buildMaterialCard(materials[index], provider);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMaterialScreen(),
            ),
          ).then((_) {
            Provider.of<MaterialProvider>(context, listen: false).loadMaterials();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Material'),
      ),
    );
  }

  Widget _buildCategoryChip(String category, MaterialProvider provider) {
    bool isSelected = provider.selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          provider.setSelectedCategory(category);
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(MaterialModel material, MaterialProvider provider) {
    final category = provider.findCategoryById(material.categoryId);
    final supplier = provider.findSupplierById(material.supplierId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: material.isLowStock
              ? Colors.orange.withAlpha(25)
              : Colors.blue.withAlpha(25),
          child: Icon(
            material.isLowStock ? Icons.warning : Icons.inventory,
            color: material.isLowStock ? Colors.orange : Colors.blue,
          ),
        ),
        title: Text(material.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (material.code != null) Text('Code: ${material.code}'),
            Text('Stock: ${material.currentStock} ${material.unit}'),
            if (material.unitPrice != null)
              Text('Price: ₹${material.unitPrice}/${material.unit}'),
            if (category != null) Text('Category: ${category.name}'),
            if (supplier != null) Text('Supplier: ${supplier.name}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (material.isLowStock)
              const Icon(Icons.warning, color: Colors.orange, size: 20),
            if (material.unitPrice != null)
              Text(
                '₹${material.totalValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: material.isLowStock ? Colors.orange : Colors.green,
                ),
              ),
          ],
        ),
        onTap: () {
          _showMaterialDetails(material, provider);
        },
        onLongPress: () {
          _showMaterialOptions(material, provider);
        },
      ),
    );
  }

  Widget _buildEmptyState(MaterialProvider provider) {
    if (provider.searchQuery.isNotEmpty || provider.selectedCategory != 'All') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'No Materials Found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing your search or filter',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                provider.clearFilters();
                _searchController.clear();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No Materials Yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first material to get started',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showMaterialDetails(MaterialModel material, MaterialProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(material.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (material.code != null) _buildDetailRow('Code', material.code!),
              if (material.description != null) _buildDetailRow('Description', material.description!),
              _buildDetailRow('Stock', '${material.currentStock} ${material.unit}'),
              if (material.unitPrice != null) _buildDetailRow('Unit Price', '₹${material.unitPrice}/${material.unit}'),
              if (material.minStockLevel != null) _buildDetailRow('Min Stock', '${material.minStockLevel} ${material.unit}'),
              if (material.maxStockLevel != null) _buildDetailRow('Max Stock', '${material.maxStockLevel} ${material.unit}'),
              _buildDetailRow(
                'Category',
                material.categoryId != null
                    ? (provider.findCategoryById(material.categoryId)?.name ?? 'Unknown')
                    : 'Uncategorized',
              ),
              if (material.supplierId != null)
                _buildDetailRow(
                  'Supplier',
                  provider.findSupplierById(material.supplierId)?.name ?? 'Unknown',
                ),
              if (material.specifications != null) _buildDetailRow('Specifications', material.specifications!),
              if (material.notes != null) _buildDetailRow('Notes', material.notes!),
              _buildDetailRow('Total Value', '₹${material.totalValue.toStringAsFixed(2)}'),
              _buildDetailRow('Stock Status', material.isLowStock ? 'Low Stock ⚠️' : 'Normal'),
              _buildDetailRow('Added On', '${material.createdAt.day}/${material.createdAt.month}/${material.createdAt.year}'),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(value)),
          ],
        )
    );
  }

  void _showMaterialOptions(MaterialModel material, MaterialProvider provider) {
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
                  _showMaterialDetails(material, provider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text('Edit Material'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit feature coming soon')),
                  );
                },
              ),
              if (material.isLowStock)
                ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.orange),
                  title: const Text('Order More'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order feature coming soon')),
                    );
                  },
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Material',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMaterial(material, provider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteMaterial(MaterialModel material, MaterialProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "${material.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteMaterial(material.id!);
    }
  }
}