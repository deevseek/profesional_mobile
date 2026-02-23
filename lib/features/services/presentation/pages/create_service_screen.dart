import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/customer/data/models/customer_model.dart';
import 'package:profesionalservis_mobile/features/customer/data/repositories/customer_repository.dart';
import 'package:profesionalservis_mobile/features/services/domain/service_payloads.dart';
import 'package:profesionalservis_mobile/features/services/presentation/pages/service_detail_screen.dart';
import 'package:profesionalservis_mobile/features/services/presentation/providers/service_providers.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  ConsumerState<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _deviceTypeController = TextEditingController();
  final _complaintController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  final _technicianController = TextEditingController();

  final _customerSearchController = TextEditingController();
  Timer? _debounce;
  List<CustomerModel> _customers = const [];
  CustomerModel? _selectedCustomer;
  bool _loadingCustomer = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _customerSearchController.addListener(_onCustomerSearch);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _deviceNameController.dispose();
    _deviceTypeController.dispose();
    _complaintController.dispose();
    _estimatedCostController.dispose();
    _technicianController.dispose();
    _customerSearchController
      ..removeListener(_onCustomerSearch)
      ..dispose();
    super.dispose();
  }

  void _onCustomerSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _loadCustomers);
  }

  Future<void> _loadCustomers() async {
    setState(() => _loadingCustomer = true);
    try {
      final repo = ref.read(customerRepositoryProvider);
      final response = await repo.getCustomers(page: 1, search: _customerSearchController.text);
      if (mounted) {
        setState(() {
          _customers = response.data;
          _loadingCustomer = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingCustomer = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createServiceProvider);
    final notifier = ref.read(createServiceProvider.notifier);
    final isSubmitting = createState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Service')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _customerSearchController,
              decoration: InputDecoration(
                hintText: 'Cari customer...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _loadingCustomer
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<CustomerModel>(
              value: _selectedCustomer,
              items: _customers
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.name} (${c.phone})'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: isSubmitting ? null : (value) => setState(() => _selectedCustomer = value),
              decoration: const InputDecoration(labelText: 'Customer'),
              validator: (value) => value == null ? 'Pilih customer' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _deviceNameController,
              decoration: const InputDecoration(labelText: 'Device name'),
              validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _deviceTypeController,
              decoration: const InputDecoration(labelText: 'Device type'),
              validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _complaintController,
              decoration: const InputDecoration(labelText: 'Keluhan'),
              minLines: 2,
              maxLines: 3,
              validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _estimatedCostController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Estimasi biaya'),
              validator: (value) => (int.tryParse(value ?? '') == null) ? 'Angka tidak valid' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _technicianController,
              decoration: const InputDecoration(labelText: 'Technician ID'),
              validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      final payload = CreateServicePayload(
                        customerId: _selectedCustomer!.id,
                        deviceName: _deviceNameController.text,
                        deviceType: _deviceTypeController.text,
                        complaint: _complaintController.text,
                        estimatedCost: int.parse(_estimatedCostController.text),
                        technicianId: _technicianController.text,
                      );

                      final created = await notifier.submit(payload);
                      if (!mounted) return;

                      if (created != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Service berhasil dibuat')),
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailScreen(serviceId: created.id),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gagal menyimpan service')),
                        );
                      }
                    },
              icon: isSubmitting
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text('Simpan Service'),
            ),
          ],
        ),
      ),
    );
  }
}
