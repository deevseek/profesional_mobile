import 'package:flutter/material.dart';

import '../domain/transaction_model.dart';
import 'transaction_controller.dart';
import 'transaction_detail_page.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final TransactionController _controller = TransactionController();
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _invoiceController.addListener(() {
      setState(() {});
    });
    _statusController.addListener(() {
      setState(() {});
    });
    _controller.loadTransactions();
  }

  @override
  void dispose() {
    _controller.dispose();
    _invoiceController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Transactions'),
            actions: [
              IconButton(
                onPressed: _controller.isLoading
                    ? null
                    : () => _controller.loadTransactions(
                          invoiceNumber: _invoiceController.text,
                          status: _statusController.text,
                          page: 1,
                        ),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(context),
              _buildStatusFilter(context),
              if (_controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildErrorBanner(_controller.errorMessage!),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _controller.loadTransactions(
                      invoiceNumber: _invoiceController.text,
                      status: _statusController.text,
                      page: _controller.page,
                    );
                  },
                  child: _buildList(context),
                ),
              ),
              _buildPagination(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SearchBar(
        controller: _invoiceController,
        hintText: 'Search by invoice number',
        leading: const Icon(Icons.search),
        trailing: [
          if (_invoiceController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _invoiceController.clear();
                _controller.loadTransactions(
                  invoiceNumber: '',
                  status: _statusController.text,
                  page: 1,
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _controller.isLoading
                ? null
                : () => _controller.loadTransactions(
                      invoiceNumber: _invoiceController.text,
                      status: _statusController.text,
                      page: 1,
                    ),
          ),
        ],
        onSubmitted: (value) {
          _controller.loadTransactions(
            invoiceNumber: value,
            status: _statusController.text,
            page: 1,
          );
        },
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _statusController,
        decoration: InputDecoration(
          labelText: 'Status',
          prefixIcon: const Icon(Icons.flag_outlined),
          suffixIcon: _statusController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _statusController.clear();
                    _controller.loadTransactions(
                      invoiceNumber: _invoiceController.text,
                      status: '',
                      page: 1,
                    );
                  },
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _controller.loadTransactions(
            invoiceNumber: _invoiceController.text,
            status: value,
            page: 1,
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_controller.isLoading && _controller.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.transactions.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _controller.transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final transaction = _controller.transactions[index];
        final statusLabel = transaction.status;
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                transaction.invoiceNumber.isNotEmpty
                    ? transaction.invoiceNumber[0].toUpperCase()
                    : '#',
              ),
            ),
            title: Text(
              transaction.invoiceNumber.isNotEmpty
                  ? 'Invoice ${transaction.invoiceNumber}'
                  : 'Transaction',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.customerName != null && transaction.customerName!.isNotEmpty)
                  Text(transaction.customerName!),
                if (transaction.totalAmount != null)
                  Text('Total: ${_formatAmount(transaction.totalAmount)}'),
                if (transaction.createdAt != null)
                  Text('Created: ${_formatDate(transaction.createdAt)}'),
                if (statusLabel != null && statusLabel.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildStatusBadge(context, statusLabel),
                ],
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => TransactionDetailPage(transactionId: transaction.id),
                ),
              );
              if (updated == true) {
                _controller.loadTransactions(
                  invoiceNumber: _invoiceController.text,
                  status: _statusController.text,
                  page: _controller.page,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildPagination(BuildContext context) {
    final meta = _controller.meta;
    if (meta == null) {
      return const SizedBox.shrink();
    }

    final canGoBack = meta.currentPage > 1;
    final canGoForward = meta.currentPage < meta.lastPage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Page ${meta.currentPage} of ${meta.lastPage} · ${meta.total} total',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            onPressed: canGoBack && !_controller.isLoading
                ? () => _controller.loadTransactions(
                      invoiceNumber: _invoiceController.text,
                      status: _statusController.text,
                      page: meta.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: canGoForward && !_controller.isLoading
                ? () => _controller.loadTransactions(
                      invoiceNumber: _invoiceController.text,
                      status: _statusController.text,
                      page: meta.currentPage + 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final label = _formatStatusLabel(status);
    final color = _statusColor(context, status);
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
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

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '—';
    }
    return value.toLocal().toString();
  }

  String _formatAmount(double? value) {
    if (value == null) {
      return '—';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  Widget _buildErrorBanner(String message) {
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
}
