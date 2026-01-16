import 'package:flutter/material.dart';

import '../domain/customer_model.dart';
import 'customer_controller.dart';

class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key, this.customer});

  final Customer? customer;

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final CustomerController _controller = CustomerController();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalController;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    _nameController = TextEditingController(text: customer?.name ?? '');
    _emailController = TextEditingController(text: customer?.email ?? '');
    _phoneController = TextEditingController(text: customer?.phone ?? '');
    _addressController = TextEditingController(text: customer?.address ?? '');
    _cityController = TextEditingController(text: customer?.city ?? '');
    _stateController = TextEditingController(text: customer?.state ?? '');
    _postalController = TextEditingController(text: customer?.postalCode ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Customer' : 'New Customer'),
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
                      prefixIcon: Icon(Icons.person_outline),
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
                    textInputAction: TextInputAction.next,
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
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  _buildFieldError('city'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  _buildFieldError('state'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _postalController,
                    decoration: const InputDecoration(
                      labelText: 'Postal code',
                      prefixIcon: Icon(Icons.local_post_office_outlined),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  _buildFieldError('postal_code'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: _controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(isEditing ? Icons.save_outlined : Icons.add),
                    label: Text(isEditing ? 'Save Changes' : 'Create Customer'),
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
            isEditing ? 'Update customer details' : 'Add a new customer',
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

    final customer = Customer(
      id: widget.customer?.id ?? '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
      postalCode: _postalController.text.trim().isEmpty ? null : _postalController.text.trim(),
    );

    final isEditing = widget.customer != null;
    final success = isEditing
        ? await _controller.updateCustomer(widget.customer!.id, customer)
        : await _controller.createCustomer(customer);

    if (!success || !mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }
}
