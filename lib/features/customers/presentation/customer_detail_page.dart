import 'package:flutter/material.dart';

import '../domain/customer_model.dart';
import 'customer_controller.dart';
import 'customer_form_page.dart';

class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final CustomerController _controller = CustomerController();

  @override
  void initState() {
    super.initState();
    _controller.loadCustomer(widget.customerId);
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
        final customer = _controller.customer;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Customer Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: customer == null
                    ? null
                    : () async {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => CustomerFormPage(customer: customer),
                          ),
                        );
                        if (updated == true) {
                          await _controller.loadCustomer(widget.customerId);
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        }
                      },
              ),
            ],
          ),
          body: _buildBody(context),
          bottomNavigationBar: customer == null
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
                        : const Text('Delete Customer'),
                    onPressed: _controller.isSubmitting
                        ? null
                        : () => _confirmDelete(context, customer),
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

    final customer = _controller.customer;
    if (customer == null) {
      return const Center(child: Text('Customer not found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(context, customer),
        const SizedBox(height: 24),
        _buildSection(context, 'Contact information', [
          _buildInfoRow('Email', customer.email),
          _buildInfoRow('Phone', customer.phone),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Address', [
          _buildInfoRow('Address', customer.address),
          _buildInfoRow('City', customer.city),
          _buildInfoRow('State', customer.state),
          _buildInfoRow('Postal code', customer.postalCode),
        ]),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Customer customer) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (customer.email != null && customer.email!.isNotEmpty)
                    Text(
                      customer.email!,
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

  Future<void> _confirmDelete(BuildContext context, Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete customer?'),
          content: Text(
            'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
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

    final success = await _controller.deleteCustomer(customer.id);
    if (!success || !context.mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }
}
