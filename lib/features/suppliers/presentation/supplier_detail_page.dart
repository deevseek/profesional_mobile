import 'package:flutter/material.dart';

import '../domain/supplier_model.dart';
import 'supplier_controller.dart';
import 'supplier_form_page.dart';

class SupplierDetailPage extends StatefulWidget {
  const SupplierDetailPage({super.key, required this.supplierId});

  final String supplierId;

  @override
  State<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends State<SupplierDetailPage> {
  final SupplierController _controller = SupplierController();

  @override
  void initState() {
    super.initState();
    _controller.loadSupplier(widget.supplierId);
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
        final supplier = _controller.supplier;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Supplier Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: supplier == null
                    ? null
                    : () async {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => SupplierFormPage(supplier: supplier),
                          ),
                        );
                        if (updated == true) {
                          await _controller.loadSupplier(widget.supplierId);
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        }
                      },
              ),
            ],
          ),
          body: _buildBody(context),
          bottomNavigationBar: supplier == null
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
                        : const Text('Delete Supplier'),
                    onPressed: _controller.isSubmitting
                        ? null
                        : () => _confirmDelete(context, supplier),
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

    final supplier = _controller.supplier;
    if (supplier == null) {
      return const Center(child: Text('Supplier not found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(context, supplier),
        const SizedBox(height: 24),
        _buildSection(context, 'Contact information', [
          _buildInfoRow('Email', supplier.email),
          _buildInfoRow('Phone', supplier.phone),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Address', [
          _buildInfoRow('Address', supplier.address),
          _buildInfoRow('City', supplier.city),
          _buildInfoRow('State', supplier.state),
          _buildInfoRow('Postal code', supplier.postalCode),
        ]),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Supplier supplier) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (supplier.email != null && supplier.email!.isNotEmpty)
                    Text(
                      supplier.email!,
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
            width: 110,
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

  Future<void> _confirmDelete(BuildContext context, Supplier supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete supplier?'),
          content: Text(
            'Are you sure you want to delete ${supplier.name}? This action cannot be undone.',
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

    final success = await _controller.deleteSupplier(supplier.id);
    if (!success || !context.mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }
}
