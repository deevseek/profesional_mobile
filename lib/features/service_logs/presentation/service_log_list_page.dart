import 'package:flutter/material.dart';

import '../domain/service_log_model.dart';
import 'service_log_controller.dart';

class ServiceLogListPage extends StatefulWidget {
  const ServiceLogListPage({super.key});

  @override
  State<ServiceLogListPage> createState() => _ServiceLogListPageState();
}

class _ServiceLogListPageState extends State<ServiceLogListPage> {
  final ServiceLogController _controller = ServiceLogController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    _controller.loadServiceLogs();
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
            title: const Text('Service Logs'),
            actions: [
              IconButton(
                onPressed: _controller.isLoading
                    ? null
                    : () => _controller.loadServiceLogs(
                          search: _searchController.text,
                          page: 1,
                        ),
                icon: const Icon(Icons.refresh),
              ),
            ],
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
                    await _controller.loadServiceLogs(
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
        hintText: 'Search by service or message',
        leading: const Icon(Icons.search),
        trailing: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _controller.loadServiceLogs(search: '', page: 1);
              },
            ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _controller.isLoading
                ? null
                : () => _controller.loadServiceLogs(
                      search: _searchController.text,
                      page: 1,
                    ),
          ),
        ],
        onSubmitted: (value) {
          _controller.loadServiceLogs(search: value, page: 1);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_controller.isLoading && _controller.serviceLogs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.serviceLogs.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.history_toggle_off_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No service logs found',
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
      itemCount: _controller.serviceLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = _controller.serviceLogs[index];
        final headline = _headline(log);
        final statusLabel = _statusLabel(log);
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                headline.isNotEmpty ? headline[0].toUpperCase() : '?',
              ),
            ),
            title: Text(headline.isNotEmpty ? headline : 'Service log'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (log.description != null && log.description!.isNotEmpty)
                  Text(log.description!),
                if (log.serviceName != null && log.serviceName!.isNotEmpty)
                  Text('Service: ${log.serviceName}'),
                if (log.serviceId != null && log.serviceId!.isNotEmpty)
                  Text('Service ID: ${log.serviceId}'),
                if (log.actor != null && log.actor!.isNotEmpty) Text('By: ${log.actor}'),
                if (log.createdAt != null) Text('Logged: ${_formatDate(log.createdAt)}'),
                if (statusLabel != null) ...[
                  const SizedBox(height: 6),
                  _buildStatusBadge(context, statusLabel),
                ],
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
                ? () => _controller.loadServiceLogs(
                      search: _searchController.text,
                      page: meta.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: canGoForward && !_controller.isLoading
                ? () => _controller.loadServiceLogs(
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
      case 'info':
      case 'notice':
        return Colors.blue.shade600;
      case 'warning':
      case 'warn':
        return Colors.orange.shade700;
      case 'error':
      case 'failed':
      case 'failure':
        return Colors.red.shade600;
      case 'success':
      case 'completed':
        return Colors.green.shade600;
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

  String _headline(ServiceLog log) {
    if (log.title != null && log.title!.isNotEmpty) {
      return log.title!;
    }
    if (log.serviceName != null && log.serviceName!.isNotEmpty) {
      return log.serviceName!;
    }
    return log.serviceId ?? '';
  }

  String? _statusLabel(ServiceLog log) {
    if (log.status != null && log.status!.isNotEmpty) {
      return log.status;
    }
    if (log.level != null && log.level!.isNotEmpty) {
      return log.level;
    }
    return null;
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '—';
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
