import 'package:flutter/material.dart';

import 'customer_controller.dart';
import 'customer_detail_page.dart';
import 'customer_form_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final CustomerController _controller = CustomerController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    _controller.loadCustomers();
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
            title: const Text('Customers'),
            actions: [
              IconButton(
                onPressed: _controller.isLoading
                    ? null
                    : () => _controller.loadCustomers(
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
                  builder: (context) => const CustomerFormPage(),
                ),
              );
              if (created == true) {
                _controller.loadCustomers(page: _controller.page);
              }
            },
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('New Customer'),
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
                    await _controller.loadCustomers(
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
        hintText: 'Search by name, email, or phone',
        leading: const Icon(Icons.search),
        trailing: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _controller.loadCustomers(search: '', page: 1);
              },
            ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _controller.isLoading
                ? null
                : () => _controller.loadCustomers(
                      search: _searchController.text,
                      page: 1,
                    ),
          ),
        ],
        onSubmitted: (value) {
          _controller.loadCustomers(search: value, page: 1);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_controller.isLoading && _controller.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.customers.isEmpty &&
        _controller.errorMessage == null &&
        _controller.hasLoadedSuccessfully) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or create a new customer.',
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
      itemCount: _controller.customers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final customer = _controller.customers[index];
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
              ),
            ),
            title: Text(customer.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customer.email != null && customer.email!.isNotEmpty)
                  Text(customer.email!),
                if (customer.phone != null && customer.phone!.isNotEmpty)
                  Text(customer.phone!),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => CustomerDetailPage(customerId: customer.id),
                ),
              );
              if (updated == true) {
                _controller.loadCustomers(page: _controller.page);
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
                ? () => _controller.loadCustomers(
                      search: _searchController.text,
                      page: meta.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: canGoForward && !_controller.isLoading
                ? () => _controller.loadCustomers(
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
