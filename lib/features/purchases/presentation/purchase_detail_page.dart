import 'package:flutter/material.dart';

import '../domain/purchase_model.dart';
import 'purchase_controller.dart';

class PurchaseDetailPage extends StatefulWidget {
  const PurchaseDetailPage({super.key, required this.purchaseId});

  final String purchaseId;

  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  final PurchaseController _controller = PurchaseController();

  @override
  void initState() {
    super.initState();
    _controller.loadPurchase(widget.purchaseId);
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Purchase Details'),
          ),
          body: _buildBody(context),
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

    final purchase = _controller.purchase;
    if (purchase == null) {
      return const Center(child: Text('Purchase not found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(context, purchase),
        const SizedBox(height: 24),
        _buildSection(context, 'Purchase', [
          _buildInfoRow('Invoice', purchase.invoiceNumber),
          _buildInfoRow('Status', _formatStatusLabel(purchase.paymentStatus)),
          _buildInfoRow('Purchase date', _formatDate(purchase.purchaseDate)),
          _buildInfoRow('Total amount', _formatAmount(purchase.totalAmount)),
          _buildInfoRow('Notes', purchase.notes),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Supplier', [
          _buildInfoRow('Name', purchase.supplierName),
        ]),
        const SizedBox(height: 16),
        _buildItemsSection(context, purchase.items ?? const []),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Purchase purchase) {
    final invoiceLabel = purchase.invoiceNumber ?? '';
    final statusLabel = _formatStatusLabel(purchase.paymentStatus);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                invoiceLabel.isNotEmpty ? invoiceLabel[0].toUpperCase() : '#',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoiceLabel.isNotEmpty ? 'Invoice $invoiceLabel' : 'Purchase',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (purchase.supplierName != null && purchase.supplierName!.isNotEmpty)
                    Text(
                      purchase.supplierName!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (statusLabel != null) ...[
                    const SizedBox(height: 8),
                    _buildStatusBadge(context, statusLabel),
                  ],
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

  Widget _buildItemsSection(BuildContext context, List<PurchaseLineItem> items) {
    if (items.isEmpty) {
      return _buildSection(context, 'Items', [
        const Text('No purchase items available.'),
      ]);
    }

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...items.map((item) => _buildItemRow(context, item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, PurchaseLineItem item) {
    final name = item.productName ?? item.productId ?? 'Item';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (item.productSku != null && item.productSku!.isNotEmpty)
            Text('SKU: ${item.productSku}'),
          if (item.quantity != null) Text('Qty: ${item.quantity}'),
          if (item.price != null) Text('Price: ${_formatAmount(item.price)}'),
          if (item.subtotal != null) Text('Subtotal: ${_formatAmount(item.subtotal)}'),
        ],
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

  Widget _buildStatusBadge(BuildContext context, String status) {
    final label = _formatStatusLabel(status) ?? 'Unknown';
    final color = _statusColor(context, status);
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _statusColor(BuildContext context, String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'paid':
        return Colors.green.shade600;
      case 'debt':
      case 'pending':
        return Colors.orange.shade700;
      case 'cancelled':
      case 'canceled':
        return Colors.red.shade600;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String? _formatStatusLabel(String? status) {
    if (status == null || status.trim().isEmpty) {
      return null;
    }
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  String? _formatAmount(double? value) {
    if (value == null) {
      return null;
    }
    return 'Rp${value.toStringAsFixed(2)}';
  }

  String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    return value.toLocal().toString();
  }
}
