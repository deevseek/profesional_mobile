import 'package:flutter/material.dart';

import '../domain/service_model.dart';
import 'service_controller.dart';
import 'service_detail_page.dart';
import 'service_form_page.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  static const List<String> _statusOptions = [
    'pending',
    'in_progress',
    'completed',
    'cancelled',
  ];

  final ServiceController _controller = ServiceController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    _controller.loadServices();
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
            title: const Text('Services'),
            actions: [
              IconButton(
                onPressed: _controller.isLoading
                    ? null
                    : () => _controller.loadServices(
                          customerName: _searchController.text,
                          status: _selectedStatus,
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
                  builder: (context) => const ServiceFormPage(),
                ),
              );
              if (created == true) {
                _controller.loadServices(page: _controller.page);
              }
            },
            icon: const Icon(Icons.add_task_outlined),
            label: const Text('New Service'),
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
                    await _controller.loadServices(
                      customerName: _searchController.text,
                      status: _selectedStatus,
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
        hintText: 'Search by customer name',
        leading: const Icon(Icons.search),
        trailing: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _controller.loadServices(customerName: '', status: _selectedStatus, page: 1);
              },
            ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _controller.isLoading
                ? null
                : () => _controller.loadServices(
                      customerName: _searchController.text,
                      status: _selectedStatus,
                      page: 1,
                    ),
          ),
        ],
        onSubmitted: (value) {
          _controller.loadServices(customerName: value, status: _selectedStatus, page: 1);
        },
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DropdownButtonFormField<String>(
        value: _selectedStatus,
        decoration: const InputDecoration(
          labelText: 'Status',
          prefixIcon: Icon(Icons.flag_outlined),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: '',
            child: Text('All statuses'),
          ),
          ..._statusOptions.map(
            (status) => DropdownMenuItem<String>(
              value: status,
              child: Text(_formatStatusLabel(status)),
            ),
          ),
        ],
        onChanged: _controller.isLoading
            ? null
            : (value) {
                setState(() {
                  _selectedStatus = value ?? '';
                });
                _controller.loadServices(
                  customerName: _searchController.text,
                  status: _selectedStatus,
                  page: 1,
                );
              },
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_controller.isLoading && _controller.services.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.services.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.support_agent_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No services found',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or create a new service.',
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
      itemCount: _controller.services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = _controller.services[index];
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                service.customerName.isNotEmpty
                    ? service.customerName[0].toUpperCase()
                    : '?',
              ),
            ),
            title: Text(service.customerName.isNotEmpty ? service.customerName : 'Service'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service.title != null && service.title!.isNotEmpty) Text(service.title!),
                if (service.scheduledAt != null)
                  Text('Scheduled: ${_formatDate(service.scheduledAt)}'),
                const SizedBox(height: 6),
                _buildStatusBadge(context, service.status),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => ServiceDetailPage(serviceId: service.id),
                ),
              );
              if (updated == true) {
                _controller.loadServices(page: _controller.page);
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
                ? () => _controller.loadServices(
                      customerName: _searchController.text,
                      status: _selectedStatus,
                      page: meta.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: canGoForward && !_controller.isLoading
                ? () => _controller.loadServices(
                      customerName: _searchController.text,
                      status: _selectedStatus,
                      page: meta.currentPage + 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    final label = _formatStatusLabel(status ?? 'unknown');
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
      case 'pending':
        return Colors.orange.shade700;
      case 'in_progress':
      case 'in progress':
        return Colors.blue.shade600;
      case 'completed':
        return Colors.green.shade600;
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

  String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    return value.toLocal().toString();
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
