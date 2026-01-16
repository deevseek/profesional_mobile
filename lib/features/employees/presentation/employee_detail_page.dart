import 'package:flutter/material.dart';

import '../domain/employee_model.dart';
import 'employee_controller.dart';
import 'employee_form_page.dart';

class EmployeeDetailPage extends StatefulWidget {
  const EmployeeDetailPage({super.key, required this.employeeId});

  final String employeeId;

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  final EmployeeController _controller = EmployeeController();

  @override
  void initState() {
    super.initState();
    _controller.loadEmployee(widget.employeeId);
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
        final employee = _controller.employee;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Employee Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: employee == null
                    ? null
                    : () async {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => EmployeeFormPage(employee: employee),
                          ),
                        );
                        if (updated == true) {
                          await _controller.loadEmployee(widget.employeeId);
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        }
                      },
              ),
            ],
          ),
          body: _buildBody(context),
          bottomNavigationBar: employee == null
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
                        : const Text('Delete Employee'),
                    onPressed: _controller.isSubmitting
                        ? null
                        : () => _confirmDelete(context, employee),
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

    final employee = _controller.employee;
    if (employee == null) {
      return const Center(child: Text('Employee not found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(context, employee),
        const SizedBox(height: 24),
        _buildSection(context, 'Contact information', [
          _buildInfoRow('Email', employee.email),
          _buildInfoRow('Phone', employee.phone),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Status', [
          _buildInfoRow('Active', employee.isActive ? 'Yes' : 'No'),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, 'Timeline', [
          _buildInfoRow('Created', _formatDate(employee.createdAt)),
          _buildInfoRow('Updated', _formatDate(employee.updatedAt)),
        ]),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Employee employee) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (employee.email != null && employee.email!.isNotEmpty)
                    Text(
                      employee.email!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
            width: 110,
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

  String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    return value.toLocal().toString();
  }

  Future<void> _confirmDelete(BuildContext context, Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete employee?'),
          content: Text(
            'Are you sure you want to delete ${employee.name}? This action cannot be undone.',
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

    final success = await _controller.deleteEmployee(employee.id);
    if (!success || !context.mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }
}
