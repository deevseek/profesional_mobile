import 'package:flutter/material.dart';

import '../domain/service_model.dart';
import 'service_controller.dart';
import 'service_form_page.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key, required this.serviceId});

  final String serviceId;

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  final ServiceController _controller = ServiceController();

  @override
  void initState() {
    super.initState();
    _controller.loadService(widget.serviceId);
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
        final service = _controller.service;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Service Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: service == null
                    ? null
                    : () async {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => ServiceFormPage(service: service),
                          ),
                        );
                        if (updated == true) {
                          await _controller.loadService(widget.serviceId);
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        }
                      },
              ),
            ],
          ),
          body: _buildBody(context),
          bottomNavigationBar: service == null
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
                        : const Text('Delete Service'),
                    onPressed:
                        _controller.isSubmitting ? null : () => _confirmDelete(context, service),
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

    final service = _controller.service;
    if (service == null) {
      return const Center(child: Text('Service not found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(context, service),
        const SizedBox(height: 24),
        _buildSection(context, 'Customer', [
          _buildInfoRow('Customer', service.customerName),
          _buildInfoRow('Status', _formatStatusLabel(service.status)),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Schedule', [
          _buildInfoRow('Scheduled', _formatDate(service.scheduledAt)),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Details', [
          _buildInfoRow('Title', service.title),
          _buildInfoRow('Description', service.description),
          _buildInfoRow('Created', _formatDate(service.createdAt)),
          _buildInfoRow('Updated', _formatDate(service.updatedAt)),
        ]),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Service service) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                service.customerName.isNotEmpty
                    ? service.customerName[0].toUpperCase()
                    : '?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.customerName.isNotEmpty ? service.customerName : 'Service',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  _buildStatusBadge(context, service.status),
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

  Widget _buildStatusBadge(BuildContext context, String? status) {
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

  String _formatStatusLabel(String? status) {
    if (status == null || status.trim().isEmpty) {
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

  Future<void> _confirmDelete(BuildContext context, Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete service?'),
          content: Text(
            'Are you sure you want to delete this service for ${service.customerName}? '
            'This action cannot be undone.',
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

    final deleted = await _controller.deleteService(service.id);
    if (!deleted) {
      return;
    }

    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
