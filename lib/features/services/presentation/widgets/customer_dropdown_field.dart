import 'package:flutter/material.dart';
import 'package:profesionalservis_mobile/features/customer/data/models/customer_model.dart';

class CustomerDropdownField extends StatelessWidget {
  const CustomerDropdownField({
    required this.customers,
    required this.selectedCustomer,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final List<CustomerModel> customers;
  final CustomerModel? selectedCustomer;
  final bool enabled;
  final ValueChanged<CustomerModel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CustomerModel>(
      value: selectedCustomer,
      items: customers
          .map(
            (customer) => DropdownMenuItem(
              value: customer,
              child: Text('${customer.name} (${customer.phone})'),
            ),
          )
          .toList(growable: false),
      onChanged: enabled ? onChanged : null,
      decoration: const InputDecoration(labelText: 'Customer'),
      validator: (value) => value == null ? 'Pilih customer' : null,
    );
  }
}
