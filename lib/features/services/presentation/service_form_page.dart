import 'package:flutter/material.dart';

import '../domain/service_model.dart';
import 'service_controller.dart';

class ServiceFormPage extends StatefulWidget {
  const ServiceFormPage({super.key, this.service});

  final Service? service;

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  static const List<String> _statusOptions = [
    'pending',
    'in_progress',
    'completed',
    'cancelled',
  ];

  final ServiceController _controller = ServiceController();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _customerController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _scheduledController;
  String _statusValue = '';

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    _customerController = TextEditingController(text: service?.customerName ?? '');
    _titleController = TextEditingController(text: service?.title ?? '');
    _descriptionController = TextEditingController(text: service?.description ?? '');
    _scheduledController = TextEditingController(text: _formatDate(service?.scheduledAt) ?? '');
    _statusValue = service?.status ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    _customerController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _scheduledController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.service != null;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Service' : 'New Service'),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(context, isEditing),
                  if (_controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildErrorBanner(context, _controller.errorMessage!),
                    ),
                  TextFormField(
                    controller: _customerController,
                    decoration: const InputDecoration(
                      labelText: 'Customer name *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Customer name is required.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('customer_name'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _statusValue.isEmpty ? null : _statusValue,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: _statusOptions
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(_formatStatusLabel(status)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _statusValue = value ?? '';
                      });
                    },
                  ),
                  _buildFieldError('status'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  _buildFieldError('title'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                  ),
                  _buildFieldError('description'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _scheduledController,
                    decoration: const InputDecoration(
                      labelText: 'Scheduled at',
                      hintText: 'YYYY-MM-DD HH:MM',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  _buildFieldError('scheduled_at'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: _controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(isEditing ? Icons.save_outlined : Icons.add),
                    label: Text(isEditing ? 'Save Changes' : 'Create Service'),
                    onPressed: _controller.isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Update service details' : 'Add a new service',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Fields marked with * are required.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
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

  Widget _buildFieldError(String field) {
    final errors = _controller.fieldErrors[field];
    if (errors == null || errors.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        errors.join('\n'),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
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

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final service = Service(
      id: widget.service?.id ?? '',
      customerName: _customerController.text.trim(),
      status: _statusValue.isEmpty ? null : _statusValue,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      scheduledAt: _parseDate(_scheduledController.text),
    );

    final success = widget.service == null
        ? await _controller.createService(service)
        : await _controller.updateService(widget.service!.id, service);

    if (!success) {
      return;
    }

    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
