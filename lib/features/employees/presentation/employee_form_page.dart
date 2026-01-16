import 'package:flutter/material.dart';

import '../domain/employee_model.dart';
import 'employee_controller.dart';

class EmployeeFormPage extends StatefulWidget {
  const EmployeeFormPage({super.key, this.employee});

  final Employee? employee;

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final EmployeeController _controller = EmployeeController();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _positionController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _joinDateController;
  late final TextEditingController _baseSalaryController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final employee = widget.employee;
    _nameController = TextEditingController(text: employee?.name ?? '');
    _positionController = TextEditingController(text: employee?.position ?? '');
    _emailController = TextEditingController(text: employee?.email ?? '');
    _phoneController = TextEditingController(text: employee?.phone ?? '');
    _addressController = TextEditingController(text: employee?.address ?? '');
    _joinDateController = TextEditingController(text: _formatDate(employee?.joinDate));
    _baseSalaryController = TextEditingController(
      text: employee?.baseSalary != null ? employee!.baseSalary!.toString() : '',
    );
    _isActive = employee?.isActive ?? true;
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _joinDateController.dispose();
    _baseSalaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.employee != null;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Employee' : 'New Employee'),
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('name'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      labelText: 'Position',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  _buildFieldError('position'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  _buildFieldError('email'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                  ),
                  _buildFieldError('phone'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  _buildFieldError('address'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _joinDateController,
                    decoration: const InputDecoration(
                      labelText: 'Join date (YYYY-MM-DD)',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                  ),
                  _buildFieldError('join_date'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _baseSalaryController,
                    decoration: const InputDecoration(
                      labelText: 'Base salary',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                  ),
                  _buildFieldError('base_salary'),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    title: const Text('Active employee'),
                    subtitle: Text(_isActive ? 'Employee can access the system' : 'Employee is inactive'),
                    value: _isActive,
                    onChanged: _controller.isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                  ),
                  _buildFieldError('is_active'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: _controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(isEditing ? Icons.save_outlined : Icons.add),
                    label: Text(isEditing ? 'Save Changes' : 'Create Employee'),
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
            isEditing ? 'Update employee details' : 'Add a new employee',
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

  Future<void> _submit() async {
    _controller.clearMessages();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final employee = Employee(
      id: widget.employee?.id ?? '',
      name: _nameController.text.trim(),
      position: _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      joinDate: _parseDate(_joinDateController.text.trim()),
      baseSalary: _parseDouble(_baseSalaryController.text.trim()),
      isActive: _isActive,
    );

    final isEditing = widget.employee != null;
    final success = isEditing
        ? await _controller.updateEmployee(widget.employee!.id, employee)
        : await _controller.createEmployee(employee);

    if (!success || !mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  double? _parseDouble(String value) {
    if (value.isEmpty) {
      return null;
    }
    return double.tryParse(value);
  }
}
