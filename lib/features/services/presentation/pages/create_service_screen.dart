import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/services/domain/service_payloads.dart';
import 'package:profesionalservis_mobile/features/services/presentation/pages/service_detail_screen.dart';
import 'package:profesionalservis_mobile/features/services/presentation/providers/service_form_provider.dart';
import 'package:profesionalservis_mobile/features/services/presentation/providers/service_providers.dart';
import 'package:profesionalservis_mobile/features/services/presentation/widgets/customer_dropdown_field.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  ConsumerState<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _deviceTypeController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _accessoriesController = TextEditingController();
  final _complaintController = TextEditingController();
  final _estimatedCostController = TextEditingController(text: '0');
  final _serviceFeeController = TextEditingController(text: '0');
  final _warrantyDaysController = TextEditingController(text: '0');
  final _customerSearchController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerAddressController = TextEditingController();

  late final ProviderSubscription<AsyncValue<void>> _submitSubscription;
  late final ProviderSubscription<ServiceFormState> _formSubscription;

  @override
  void initState() {
    super.initState();
    _registerControllerListeners();

    _submitSubscription = ref.listenManual<AsyncValue<void>>(
      createServiceProvider,
      (previous, next) {
        if (next.hasError && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal menyimpan service')),
            );
          });
        }
      },
    );

    _formSubscription = ref.listenManual<ServiceFormState>(serviceFormProvider, (previous, next) {
      _syncController(_customerSearchController, next.customerSearch);
      _syncController(_customerNameController, next.customerName);
      _syncController(_customerPhoneController, next.customerPhone);
      _syncController(_customerEmailController, next.customerEmail);
      _syncController(_customerAddressController, next.customerAddress);
      _syncController(_deviceNameController, next.deviceName);
      _syncController(_deviceTypeController, next.deviceType);
      _syncController(_serialNumberController, next.serialNumber);
      _syncController(_accessoriesController, next.accessories);
      _syncController(_complaintController, next.complaint);
      _syncController(_estimatedCostController, next.deposit);
      _syncController(_serviceFeeController, next.serviceFee);
      _syncController(_warrantyDaysController, next.warrantyDays);
    });
  }

  void _registerControllerListeners() {
    _customerSearchController.addListener(() {
      ref.read(serviceFormProvider.notifier).setCustomerSearch(_customerSearchController.text);
    });
    _customerNameController.addListener(() {
      ref.read(serviceFormProvider.notifier).setCustomerName(_customerNameController.text);
    });
    _customerPhoneController.addListener(() {
      ref.read(serviceFormProvider.notifier).setCustomerPhone(_customerPhoneController.text);
    });
    _customerEmailController.addListener(() {
      ref.read(serviceFormProvider.notifier).setCustomerEmail(_customerEmailController.text);
    });
    _customerAddressController.addListener(() {
      ref.read(serviceFormProvider.notifier).setCustomerAddress(_customerAddressController.text);
    });
    _deviceNameController.addListener(() {
      ref.read(serviceFormProvider.notifier).setDeviceName(_deviceNameController.text);
    });
    _deviceTypeController.addListener(() {
      ref.read(serviceFormProvider.notifier).setDeviceType(_deviceTypeController.text);
    });
    _serialNumberController.addListener(() {
      ref.read(serviceFormProvider.notifier).setSerialNumber(_serialNumberController.text);
    });
    _accessoriesController.addListener(() {
      ref.read(serviceFormProvider.notifier).setAccessories(_accessoriesController.text);
    });
    _complaintController.addListener(() {
      ref.read(serviceFormProvider.notifier).setComplaint(_complaintController.text);
    });
    _estimatedCostController.addListener(() {
      ref.read(serviceFormProvider.notifier).setDeposit(_estimatedCostController.text);
    });
    _serviceFeeController.addListener(() {
      ref.read(serviceFormProvider.notifier).setServiceFee(_serviceFeeController.text);
    });
    _warrantyDaysController.addListener(() {
      ref.read(serviceFormProvider.notifier).setWarrantyDays(_warrantyDaysController.text);
    });
  }

  void _syncController(TextEditingController controller, String nextValue) {
    if (controller.text == nextValue) {
      return;
    }

    controller.value = controller.value.copyWith(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
      composing: TextRange.empty,
    );
  }

  @override
  void dispose() {
    _submitSubscription.close();
    _formSubscription.close();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _customerAddressController.dispose();
    _deviceNameController.dispose();
    _deviceTypeController.dispose();
    _serialNumberController.dispose();
    _accessoriesController.dispose();
    _complaintController.dispose();
    _estimatedCostController.dispose();
    _serviceFeeController.dispose();
    _warrantyDaysController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(serviceFormProvider);
    final createState = ref.watch(createServiceProvider);
    final isSubmitting = createState.isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Tambah Service')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _customerSearchController,
                  decoration: InputDecoration(
                    hintText: 'Cari customer...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: formState.isLoadingCustomers
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
                CustomerDropdownField(
                  customers: formState.customers,
                  selectedCustomer: formState.selectedCustomer,
                  enabled: !isSubmitting,
                  onChanged: (value) {
                    ref.read(serviceFormProvider.notifier).setCustomer(value);
                  },
                ),

                const SizedBox(height: 10),
                TextFormField(
                  controller: _customerNameController,
                  enabled: !isSubmitting,
                  decoration: const InputDecoration(labelText: 'Nama customer (opsional jika pilih dari daftar)'),
                  validator: (value) {
                    final hasSelection = formState.selectedCustomer != null;
                    final hasName = (value ?? '').trim().isNotEmpty;
                    if (!hasSelection && !hasName) {
                      return 'Pilih customer atau isi nama customer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customerPhoneController,
                  enabled: !isSubmitting,
                  decoration: const InputDecoration(labelText: 'Telepon customer (opsional)'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customerEmailController,
                  enabled: !isSubmitting,
                  decoration: const InputDecoration(labelText: 'Email customer (opsional)'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = (value ?? '').trim();
                    if (email.isEmpty) {
                      return null;
                    }
                    final isValidEmail = email.contains('@') && email.contains('.');
                    return isValidEmail ? null : 'Format email tidak valid';
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customerAddressController,
                  enabled: !isSubmitting,
                  decoration: const InputDecoration(labelText: 'Alamat customer (opsional)'),
                  maxLines: 2,
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
                  controller: _serialNumberController,
                  decoration: const InputDecoration(labelText: 'Serial Number (opsional)'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _accessoriesController,
                  decoration: const InputDecoration(labelText: 'Aksesoris (opsional)'),
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
                  decoration: const InputDecoration(labelText: 'Deposit'),
                  validator: (value) => (int.tryParse(value ?? '') == null) ? 'Angka tidak valid' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _serviceFeeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Biaya jasa'),
                  validator: (value) => (int.tryParse(value ?? '') == null) ? 'Angka tidak valid' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _warrantyDaysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Garansi (hari)'),
                  validator: (value) => (int.tryParse(value ?? '') == null) ? 'Angka tidak valid' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final selectedCustomer = formState.selectedCustomer;

                          final payload = CreateServicePayload(
                            customerId: selectedCustomer?.id,
                            customerName: selectedCustomer == null ? _customerNameController.text.trim() : null,
                            customerPhone: selectedCustomer == null ? _customerPhoneController.text.trim() : null,
                            customerEmail: selectedCustomer == null ? _customerEmailController.text.trim() : null,
                            customerAddress: selectedCustomer == null ? _customerAddressController.text.trim() : null,
                            device: _deviceNameController.text,
                            model: _deviceTypeController.text,
                            serialNumber: _serialNumberController.text,
                            accessories: _accessoriesController.text,
                            complaint: _complaintController.text,
                            deposit: int.parse(_estimatedCostController.text),
                            serviceFee: int.parse(_serviceFeeController.text),
                            warrantyDays: int.parse(_warrantyDaysController.text),
                          );

                          final created = await ref.read(createServiceProvider.notifier).submit(payload);
                          if (!mounted || created == null) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Service berhasil dibuat')),
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailScreen(serviceId: created.id),
                            ),
                          );
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
        ),
      ),
    );
  }
}
