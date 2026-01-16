import 'package:flutter/material.dart';

import '../domain/product_model.dart';
import 'product_controller.dart';
import 'product_form_page.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductController _controller = ProductController();

  @override
  void initState() {
    super.initState();
    _controller.loadProduct(widget.productId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final product = _controller.product;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Product Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: product == null
                    ? null
                    : () async {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => ProductFormPage(product: product),
                          ),
                        );
                        if (updated == true) {
                          await _controller.loadProduct(widget.productId);
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        }
                      },
              ),
            ],
          ),
          body: _buildBody(context),
          bottomNavigationBar: product == null
              ? null
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: _controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Delete Product'),
                    onPressed: _controller.isSubmitting
                        ? null
                        : () => _confirmDelete(context, product),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return Center(child: Text(_controller.errorMessage!));
    }

    final product = _controller.product;
    if (product == null) {
      return const Center(child: Text('Product not found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(context, product),
        const SizedBox(height: 24),
        _buildSection(context, 'Pricing', [
          _buildInfoRow('Pricing mode', _formatPricingMode(product.pricingMode)),
          _buildInfoRow('Price', _formatPrice(product.price)),
          _buildInfoRow('Cost', _formatPrice(product.cost)),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Inventory', [
          _buildInfoRow('Stock', product.stock?.toString()),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Details', [
          _buildInfoRow('SKU', product.sku),
          _buildInfoRow('Description', product.description),
        ]),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Product product) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (product.sku.isNotEmpty)
                    Text(
                      'SKU: ${product.sku}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final filtered = children.where((widget) => widget is! SizedBox).toList();
    if (filtered.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...filtered,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete product?'),
          content: Text(
            'Are you sure you want to delete ${product.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success = await _controller.deleteProduct(product.id);
    if (!success || !context.mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  String? _formatPrice(double? value) {
    if (value == null) {
      return null;
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  String? _formatPricingMode(String? mode) {
    if (mode == null || mode.isEmpty) {
      return null;
    }
    return mode.replaceAll('_', ' ').split(' ').map((part) {
      if (part.isEmpty) {
        return part;
      }
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).join(' ');
  }
}
