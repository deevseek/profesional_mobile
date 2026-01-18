import 'package:flutter/material.dart';

import 'purchase_item_controller.dart';

class PurchaseItemListPage extends StatefulWidget {
  const PurchaseItemListPage({super.key});

  @override
  State<PurchaseItemListPage> createState() => _PurchaseItemListPageState();
}

class _PurchaseItemListPageState extends State<PurchaseItemListPage> {
  final PurchaseItemController _controller = PurchaseItemController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _purchaseIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    _purchaseIdController.addListener(() {
      setState(() {});
    });
    _controller.loadPurchaseItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _purchaseIdController.dispose();
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
                    : () => _controller.loadPurchaseItems(
                          search: _searchController.text,
                          purchaseId: _purchaseIdController.text,
                          page: 1,
                        ),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(context),
              _buildPurchaseFilter(context),
              if (_controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildErrorBanner(_controller.errorMessage!),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _controller.loadPurchaseItems(
                      search: _searchController.text,
                      purchaseId: _purchaseIdController.text,
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
        hintText: 'Search by item or product name',
        leading: const Icon(Icons.search),
        trailing: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _controller.loadPurchaseItems(
                  search: '',
                  purchaseId: _purchaseIdController.text,
                  page: 1,
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _controller.isLoading
                ? null
                : () => _controller.loadPurchaseItems(
                      search: _searchController.text,
                      purchaseId: _purchaseIdController.text,
                      page: 1,
                    ),
          ),
        ],
        onSubmitted: (value) {
          _controller.loadPurchaseItems(
            search: value,
            purchaseId: _purchaseIdController.text,
            page: 1,
          );
        },
      ),
    );
  }

  Widget _buildPurchaseFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _purchaseIdController,
        decoration: InputDecoration(
          labelText: 'Purchase ID',
          prefixIcon: const Icon(Icons.receipt_long_outlined),
          suffixIcon: _purchaseIdController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _purchaseIdController.clear();
                    _controller.loadPurchaseItems(
                      search: _searchController.text,
                      purchaseId: '',
                      page: 1,
                    );
                  },
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _controller.loadPurchaseItems(
            search: _searchController.text,
            purchaseId: value,
            page: 1,
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_controller.isLoading && _controller.purchaseItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.purchaseItems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No purchase items found',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or refresh the list.',
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
      itemCount: _controller.purchaseItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final purchaseItem = _controller.purchaseItems[index];
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                purchaseItem.name.isNotEmpty ? purchaseItem.name[0].toUpperCase() : '?',
              ),
            ),
            title: Text(purchaseItem.name.isNotEmpty ? purchaseItem.name : 'Purchase Item'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasValue(purchaseItem.purchaseNumber))
                  Text('Purchase: ${purchaseItem.purchaseNumber}'),
                if (_hasValue(purchaseItem.supplierName))
                  Text('Supplier: ${purchaseItem.supplierName}'),
                if (_hasValue(purchaseItem.productName))
                  Text('Product: ${purchaseItem.productName}'),
                if (purchaseItem.quantity != null) Text('Qty: ${purchaseItem.quantity}'),
                if (purchaseItem.unitPrice != null)
                  Text('Unit price: ${_formatPrice(purchaseItem.unitPrice)}'),
                if (purchaseItem.total != null)
                  Text('Total: ${_formatPrice(purchaseItem.total)}'),
              ],
            ),
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
                ? () => _controller.loadPurchaseItems(
                      search: _searchController.text,
                      purchaseId: _purchaseIdController.text,
                      page: meta.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: canGoForward && !_controller.isLoading
                ? () => _controller.loadPurchaseItems(
                      search: _searchController.text,
                      purchaseId: _purchaseIdController.text,
                      page: meta.currentPage + 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
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

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _formatPrice(double? value) {
    if (value == null) {
      return '—';
    }
    return '\$${value.toStringAsFixed(2)}';
  }
}
