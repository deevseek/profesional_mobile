import 'package:flutter/material.dart';

import '../domain/purchase_model.dart';
import 'purchase_controller.dart';
import 'purchase_detail_page.dart';
import 'purchase_form_page.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  final PurchaseController _controller = PurchaseController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    _controller.loadPurchases();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Purchases'),
            actions: [
              IconButton(
                onPressed: _controller.isLoading
                    ? null
                    : () => _controller.loadPurchases(
                          search: _searchController.text,
                          page: 1,
                        ),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const PurchaseFormPage(),
                ),
              );
              if (created == true) {
                _controller.loadPurchases(
                  search: _searchController.text,
                  page: _controller.page,
                );
              }
            },
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: const Text('New Purchase'),
          ),
          body: Column(
            children: [
              _buildSearchBar(context),
              if (_controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildErrorBanner(_controller.errorMessage!),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _controller.loadPurchases(
                      search: _searchController.text,
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
        controller: _searchController,
        hintText: 'Search by invoice, supplier, or notes',
        leading: const Icon(Icons.search),
        trailing: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _controller.loadPurchases(
                  search: '',
                  page: 1,
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _controller.isLoading
                ? null
                : () => _controller.loadPurchases(
                      search: _searchController.text,
                      page: 1,
                    ),
          ),
        ],
        onSubmitted: (value) {
          _controller.loadPurchases(
            search: value,
            page: 1,
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_controller.isLoading && _controller.purchases.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.purchases.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No purchases found',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      itemCount: _controller.purchases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final purchase = _controller.purchases[index];
        final statusLabel = purchase.paymentStatus;
        final invoiceLabel = purchase.invoiceNumber ?? '';
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                invoiceLabel.isNotEmpty ? invoiceLabel[0].toUpperCase() : '#',
              ),
            ),
            title: Text(
              invoiceLabel.isNotEmpty ? 'Invoice $invoiceLabel' : 'Purchase',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (purchase.supplierName != null && purchase.supplierName!.isNotEmpty)
                  Text(purchase.supplierName!),
                if (purchase.totalAmount != null)
                  Text('Total: ${_formatAmount(purchase.totalAmount)}'),
                if (purchase.purchaseDate != null)
                  Text('Date: ${_formatDate(purchase.purchaseDate)}'),
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
                  builder: (context) => PurchaseDetailPage(purchaseId: purchase.id),
                ),
              );
              if (updated == true) {
                _controller.loadPurchases(
                  search: _searchController.text,
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
                ? () => _controller.loadPurchases(
                      search: _searchController.text,
                      page: meta.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: canGoForward && !_controller.isLoading
                ? () => _controller.loadPurchases(
                      search: _searchController.text,
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
    return 'Rp${value.toStringAsFixed(2)}';
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
