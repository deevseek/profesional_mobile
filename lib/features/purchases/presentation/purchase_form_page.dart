import 'package:flutter/material.dart';

import '../../products/domain/product_model.dart';
import '../../products/presentation/product_controller.dart';
import '../domain/purchase_model.dart';
import 'purchase_controller.dart';

class PurchaseFormPage extends StatefulWidget {
  const PurchaseFormPage({super.key});

  @override
  State<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends State<PurchaseFormPage> {
  static const List<String> _statusOptions = [
    'pending',
    'paid',
    'debt',
    'cancelled',
  ];

  final PurchaseController _controller = PurchaseController();
  final ProductController _productController = ProductController();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _supplierIdController;
  late final TextEditingController _purchaseDateController;
  late final TextEditingController _notesController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  String _statusValue = '';
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _supplierIdController = TextEditingController();
    _purchaseDateController = TextEditingController(text: _formatDate(DateTime.now()));
    _notesController = TextEditingController();
    _quantityController = TextEditingController();
    _priceController = TextEditingController();
    _productController.loadProducts(perPage: 100);
  }

  @override
  void dispose() {
    _controller.dispose();
    _productController.dispose();
    _supplierIdController.dispose();
    _purchaseDateController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _productController]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('New Purchase'),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(context),
                  if (_controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildErrorBanner(context, _controller.errorMessage!),
                    ),
                  TextFormField(
                    controller: _supplierIdController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier ID *',
                      prefixIcon: Icon(Icons.local_shipping_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Supplier ID is required.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('supplier_id'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _purchaseDateController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase date *',
                      hintText: 'YYYY-MM-DD',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Purchase date is required.';
                      }
                      if (_parseDate(value) == null) {
                        return 'Enter a valid date (YYYY-MM-DD).';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('purchase_date'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _statusValue.isEmpty ? null : _statusValue,
                    decoration: const InputDecoration(
                      labelText: 'Payment status',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    items: _statusOptions
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(_formatStatusLabel(status)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _statusValue = value ?? '';
                      });
                    },
                  ),
                  _buildFieldError('payment_status'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                  ),
                  _buildFieldError('notes'),
                  const SizedBox(height: 24),
                  Text(
                    'Items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildProductSelector(),
                  _buildFieldError('items.0.product_id'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      prefixIcon: Icon(Icons.numbers_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Quantity is required.';
                      }
                      final parsed = int.tryParse(value.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid quantity.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('items.0.quantity'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price *',
                      prefixIcon: Icon(Icons.attach_money_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Price is required.';
                      }
                      final parsed = double.tryParse(value.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid price.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('items.0.price'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: _controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: const Text('Create Purchase'),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a new purchase',
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

  Widget _buildProductSelector() {
    final products = _productController.products;
    final isLoading = _productController.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedProductId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Product *',
            prefixIcon: const Icon(Icons.inventory_2_outlined),
            suffixIcon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          items: products
              .map(
                (product) => DropdownMenuItem<String>(
                  value: product.id,
                  child: Text(
                    _formatProductLabel(product),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: isLoading
              ? null
              : (value) {
                  setState(() {
                    _selectedProductId = value;
                  });
                },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Product is required.';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        if (!isLoading && products.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No products found. Please add a product first.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (_productController.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _productController.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  String _formatProductLabel(Product product) {
    final sku = product.sku;
    if (sku != null && sku.trim().isNotEmpty) {
      return '${product.name} ($sku)';
    }
    return product.name;
  }

  String _formatStatusLabel(String status) {
    if (status.trim().isEmpty) {
      return 'Unknown';
    }
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim());
  }

  Future<void> _submit() async {
    _controller.clearError();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final purchase = Purchase(
      id: '',
      supplierId: _supplierIdController.text.trim(),
      purchaseDate: _parseDate(_purchaseDateController.text),
      paymentStatus: _statusValue.isEmpty ? null : _statusValue,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      items: [
        PurchaseLineItem(
          id: '',
          productId: _selectedProductId?.trim(),
          quantity: int.tryParse(_quantityController.text.trim()),
          price: double.tryParse(_priceController.text.trim()),
        ),
      ],
    );

    final success = await _controller.createPurchase(purchase);
    if (!success || !mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }
}
