import 'package:flutter/material.dart';

import 'employee_controller.dart';
import 'employee_detail_page.dart';
import 'employee_form_page.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final EmployeeController _controller = EmployeeController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    _controller.loadEmployees();
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
            title: const Text('Employees'),
            actions: [
              IconButton(
                onPressed: _controller.isLoading
                    ? null
                    : () => _controller.loadEmployees(
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
                  builder: (context) => const EmployeeFormPage(),
                ),
              );
              if (created == true) {
                _controller.loadEmployees(page: _controller.page);
              }
            },
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('New Employee'),
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
                    await _controller.loadEmployees(
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
                _controller.loadEmployees(search: '', page: 1);
              },
            ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _controller.isLoading
                ? null
                : () => _controller.loadEmployees(
                      search: _searchController.text,
                      page: 1,
                    ),
          ),
        ],
        onSubmitted: (value) {
          _controller.loadEmployees(search: value, page: 1);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_controller.isLoading && _controller.employees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.employees.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.badge_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No employees found',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or create a new employee.',
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
      itemCount: _controller.employees.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final employee = _controller.employees[index];
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
              ),
            ),
            title: Text(employee.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (employee.email != null && employee.email!.isNotEmpty)
                  Text(employee.email!),
                if (employee.phone != null && employee.phone!.isNotEmpty)
                  Text(employee.phone!),
                const SizedBox(height: 4),
                _buildStatusChip(context, employee.isActive),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => EmployeeDetailPage(employeeId: employee.id),
                ),
              );
              if (updated == true) {
                _controller.loadEmployees(page: _controller.page);
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
                ? () => _controller.loadEmployees(
                      search: _searchController.text,
                      page: meta.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: canGoForward && !_controller.isLoading
                ? () => _controller.loadEmployees(
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

  Widget _buildStatusChip(BuildContext context, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = isActive ? 'Active' : 'Inactive';
    final background = isActive ? colorScheme.primaryContainer : colorScheme.surfaceVariant;
    final foreground = isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;

    return Chip(
      label: Text(label),
      labelStyle: TextStyle(color: foreground),
      backgroundColor: background,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
