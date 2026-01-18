import 'package:flutter/material.dart';

import '../../categories/presentation/category_controller.dart';
import '../domain/product_model.dart';
import 'product_controller.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  static const List<String> _pricingModes = [
    'manual',
    'percentage',
  ];

  final ProductController _controller = ProductController();
  final CategoryController _categoryController = CategoryController();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _costController;
  late final TextEditingController _marginController;
  late final TextEditingController _stockController;
  late final TextEditingController _warrantyController;
  late String _pricingMode;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _skuController = TextEditingController(text: product?.sku ?? '');
    _descriptionController = TextEditingController(text: product?.description ?? '');
    _priceController = TextEditingController(text: product?.price?.toString() ?? '');
    _costController = TextEditingController(text: product?.costPrice?.toString() ?? '');
    _marginController = TextEditingController(text: product?.marginPercentage?.toString() ?? '');
    _stockController = TextEditingController(text: product?.stock?.toString() ?? '');
    _warrantyController = TextEditingController(text: product?.warrantyDays?.toString() ?? '');
    _pricingMode = product?.pricingMode?.toString().isNotEmpty == true
        ? product!.pricingMode!
        : _pricingModes.first;
    _selectedCategoryId = product?.categoryId ?? product?.category?.id;
    _categoryController.loadCategories(perPage: 100);
  }

  @override
  void dispose() {
    _controller.dispose();
    _categoryController.dispose();
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _marginController.dispose();
    _stockController.dispose();
    _warrantyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _categoryController]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Product' : 'New Product'),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(context, isEditing),
                  if (_controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildErrorBanner(context, _controller.errorMessage!),
                    ),
                  _buildCategoryField(),
                  _buildFieldError('category_id'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('name'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('sku'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    minLines: 3,
                    maxLines: 5,
                  ),
                  _buildFieldError('description'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _pricingMode,
                    decoration: const InputDecoration(
                      labelText: 'Pricing mode',
                      prefixIcon: Icon(Icons.price_change_outlined),
                    ),
                    items: _pricingModes
                        .map(
                          (mode) => DropdownMenuItem(
                            value: mode,
                            child: Text(_formatPricingMode(mode)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _pricingMode = value;
                      });
                    },
                  ),
                  _buildFieldError('pricing_mode'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixIcon: Icon(Icons.attach_money_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: _pricingMode == 'manual',
                    validator: (value) {
                      if (_pricingMode != 'manual') {
                        return null;
                      }
                      if (value == null || value.trim().isEmpty) {
                        return 'Price is required for manual pricing.';
                      }
                      if (_parseDouble(value) == null) {
                        return 'Enter a valid price.';
                      }
                      return null;
                    },
                  ),
                  _buildFieldError('price'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Cost price',
                      prefixIcon: Icon(Icons.request_quote_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (_pricingMode != 'percentage') {
                        return null;
                      }
                      if (value == null || value.trim().isEmpty) {
                        return 'Cost price is required for percentage pricing.';
                      }
                      final parsed = _parseDouble(value);
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid cost price.';
                      }
                      return null;
                    },
                  ),
                  _buildFieldError('cost_price'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _marginController,
                    decoration: const InputDecoration(
                      labelText: 'Margin percentage',
                      prefixIcon: Icon(Icons.percent_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (_pricingMode != 'percentage') {
                        return null;
                      }
                      if (value == null || value.trim().isEmpty) {
                        return 'Margin percentage is required for percentage pricing.';
                      }
                      if (_parseDouble(value) == null) {
                        return 'Enter a valid margin percentage.';
                      }
                      return null;
                    },
                  ),
                  _buildFieldError('margin_percentage'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      prefixIcon: Icon(Icons.warehouse_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Stock is required.';
                      }
                      final parsed = _parseInt(value);
                      if (parsed == null) {
                        return 'Enter a valid stock quantity.';
                      }
                      if (parsed < 0) {
                        return 'Stock must be at least 0.';
                      }
                      return null;
                    },
                  ),
                  _buildFieldError('stock'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _warrantyController,
                    decoration: const InputDecoration(
                      labelText: 'Warranty (days)',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return null;
                      }
                      if (_parseInt(value) == null) {
                        return 'Enter a valid warranty duration.';
                      }
                      return null;
                    },
                  ),
                  _buildFieldError('warranty_days'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: _controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(isEditing ? Icons.save_outlined : Icons.add),
                    label: Text(isEditing ? 'Save Changes' : 'Create Product'),
                    onPressed: _controller.isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Update product details' : 'Add a new product',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Fields marked with * are required.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    final categories = _categoryController.categories;
    if (categories.isEmpty) {
      return TextFormField(
        initialValue: _selectedCategoryId ?? '',
        decoration: const InputDecoration(
          labelText: 'Category ID',
          prefixIcon: Icon(Icons.category_outlined),
        ),
        textInputAction: TextInputAction.next,
        onChanged: (value) {
          _selectedCategoryId = value.trim().isEmpty ? null : value.trim();
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Category is required.';
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: categories
          .map(
            (category) => DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Category is required.';
        }
        return null;
      },
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
        title: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  Widget _buildFieldError(String field) {
    final errors = _controller.fieldErrors[field];
    if (errors == null || errors.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        errors.join('\n'),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  Future<void> _submit() async {
    _controller.clearMessages();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final product = Product(
      id: widget.product?.id ?? '',
      categoryId: _selectedCategoryId?.trim().isEmpty == true ? null : _selectedCategoryId,
      name: _nameController.text.trim(),
      sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      pricingMode: _pricingMode,
      price: _parseDouble(_priceController.text),
      costPrice: _parseDouble(_costController.text),
      marginPercentage: _parseDouble(_marginController.text),
      stock: _parseInt(_stockController.text),
      warrantyDays: _parseInt(_warrantyController.text),
    );

    final isEditing = widget.product != null;
    final success = isEditing
        ? await _controller.updateProduct(widget.product!.id, product)
        : await _controller.createProduct(product);

    if (!success || !mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  double? _parseDouble(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed.replaceAll(',', ''));
  }

  int? _parseInt(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    return int.tryParse(trimmed.replaceAll(',', ''));
  }

  String _formatPricingMode(String mode) {
    if (mode.isEmpty) {
      return mode;
    }
    return mode.replaceAll('_', ' ').split(' ').map((part) {
      if (part.isEmpty) {
        return part;
      }
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).join(' ');
  }
}
