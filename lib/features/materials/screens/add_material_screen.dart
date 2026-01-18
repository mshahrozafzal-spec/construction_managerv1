import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_manager/state/material_provider.dart';
import 'package:construction_manager/data/models/material_model.dart';
import 'package:construction_manager/data/models/material_category_model.dart';
import 'package:construction_manager/data/models/supplier_model.dart';

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '5');
  final _maxStockController = TextEditingController(text: '100');
  final _priceController = TextEditingController();
  final _specificationsController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedUnit = 'pieces';
  String? _selectedCategory;
  String? _selectedSupplier;

  final List<String> _units = [
    'pieces', 'kg', 'bags', 'cubic meters', 'liters',
    'bundles', 'rolls', 'sheets', 'meters', 'tons'
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<MaterialProvider>(context, listen: false);
      provider.loadMaterials();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _priceController.dispose();
    _specificationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Material'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMaterial,
          ),
        ],
      ),
      body: Consumer<MaterialProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
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
                              labelText: 'Material Name *',
                              prefixIcon: const Icon(Icons.inventory),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Material name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              labelText: 'Material Code (SKU)',
                              prefixIcon: const Icon(Icons.code),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              prefixIcon: const Icon(Icons.description),
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

                  const SizedBox(height: 16),

                  // Category & Supplier Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category & Supplier',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Select Category'),
                              ),
                              ...provider.categories.map((category) {
                                return DropdownMenuItem(
                                  value: category.name,
                                  child: Text(category.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedSupplier,
                            decoration: InputDecoration(
                              labelText: 'Supplier (Optional)',
                              prefixIcon: const Icon(Icons.business),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Select Supplier'),
                              ),
                              ...provider.suppliers.map((supplier) {
                                return DropdownMenuItem(
                                  value: supplier.name,
                                  child: Text(supplier.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSupplier = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stock Information Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stock Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Current Stock',
                                    prefixIcon: const Icon(Icons.inventory_2),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedUnit,
                                  decoration: InputDecoration(
                                    labelText: 'Unit',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  items: _units.map((unit) {
                                    return DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedUnit = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _minStockController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Min Stock Level',
                                    prefixIcon: const Icon(Icons.warning),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _maxStockController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Max Stock Level',
                                    prefixIcon: const Icon(Icons.storage),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Price Information Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Price Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Unit Price (₹)',
                              prefixIcon: const Icon(Icons.currency_rupee),
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

                  // Additional Information Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Additional Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _specificationsController,
                            decoration: InputDecoration(
                              labelText: 'Specifications',
                              prefixIcon: const Icon(Icons.settings),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLines: 3,
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
                            maxLines: 4,
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
                      onPressed: _saveMaterial,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Save Material',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveMaterial() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<MaterialProvider>(context, listen: false);

      try {
        // Find category ID
        int? categoryId;
        if (_selectedCategory != null) {
          final category = provider.categories.firstWhere(
                (c) => c.name == _selectedCategory,
            orElse: () => MaterialCategoryModel(name: '', createdAt: DateTime.now()),
          );
          categoryId = category.id;
        }

        // Find supplier ID
        int? supplierId;
        if (_selectedSupplier != null) {
          final supplier = provider.suppliers.firstWhere(
                (s) => s.name == _selectedSupplier,
            orElse: () => SupplierModel(name: '', createdAt: DateTime.now()),
          );
          supplierId = supplier.id;
        }

        final material = MaterialModel(
          name: _nameController.text,
          code: _codeController.text.isNotEmpty ? _codeController.text : null,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          categoryId: categoryId,
          currentStock: double.tryParse(_stockController.text) ?? 0,
          unit: _selectedUnit,
          minStockLevel: double.tryParse(_minStockController.text),
          maxStockLevel: double.tryParse(_maxStockController.text),
          unitPrice: double.tryParse(_priceController.text),
          supplierId: supplierId,
          specifications: _specificationsController.text.isNotEmpty
              ? _specificationsController.text
              : null,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          createdAt: DateTime.now(),
        );

        await provider.addMaterial(material);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material added successfully'),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}