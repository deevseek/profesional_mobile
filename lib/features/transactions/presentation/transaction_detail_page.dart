import 'package:flutter/material.dart';

import '../domain/transaction_model.dart';
import 'transaction_controller.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({super.key, required this.transactionId});

  final String transactionId;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final TransactionController _controller = TransactionController();

  @override
  void initState() {
    super.initState();
    _controller.loadTransaction(widget.transactionId);
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
            title: const Text('Transaction Details'),
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

    final transaction = _controller.transaction;
    if (transaction == null) {
      return const Center(child: Text('Transaction not found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(context, transaction),
        const SizedBox(height: 24),
        _buildSection(context, 'Payment', [
          _buildInfoRow('Invoice', transaction.invoiceNumber),
          _buildInfoRow('Status', _formatStatusLabel(transaction.status)),
          _buildInfoRow('Payment method', transaction.paymentMethod),
          _buildInfoRow('Total amount', _formatAmount(transaction.totalAmount)),
          _buildInfoRow('Paid amount', _formatAmount(transaction.paidAmount)),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Customer', [
          _buildInfoRow('Name', transaction.customerName),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Notes', [
          _buildInfoRow('Notes', transaction.notes),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Timeline', [
          _buildInfoRow('Created at', _formatDate(transaction.createdAt)),
          _buildInfoRow('Updated at', _formatDate(transaction.updatedAt)),
        ]),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Transaction transaction) {
    final statusLabel = _formatStatusLabel(transaction.status);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                transaction.invoiceNumber.isNotEmpty
                    ? transaction.invoiceNumber[0].toUpperCase()
                    : '#',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.invoiceNumber.isNotEmpty
                        ? 'Invoice ${transaction.invoiceNumber}'
                        : 'Transaction',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (transaction.customerName != null && transaction.customerName!.isNotEmpty)
                    Text(
                      transaction.customerName!,
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
      case 'completed':
      case 'success':
        return Colors.green.shade600;
      case 'pending':
      case 'processing':
        return Colors.orange.shade700;
      case 'failed':
      case 'cancelled':
      case 'canceled':
        return Colors.red.shade600;
      case 'refunded':
        return Colors.blueGrey.shade600;
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
    return '\$${value.toStringAsFixed(2)}';
  }

  String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    return value.toLocal().toString();
  }
}
