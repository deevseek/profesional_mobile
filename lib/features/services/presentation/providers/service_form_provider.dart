import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/customer/data/models/customer_model.dart';
import 'package:profesionalservis_mobile/features/customer/data/repositories/customer_repository.dart';

class ServiceFormState {
  const ServiceFormState({
    this.selectedCustomer,
    this.customers = const [],
    this.customerSearch = '',
    this.deviceName = '',
    this.deviceType = '',
    this.serialNumber = '',
    this.accessories = '',
    this.complaint = '',
    this.deposit = '0',
    this.serviceFee = '0',
    this.warrantyDays = '0',
    this.isLoadingCustomers = false,
  });

  final CustomerModel? selectedCustomer;
  final List<CustomerModel> customers;
  final String customerSearch;
  final String deviceName;
  final String deviceType;
  final String serialNumber;
  final String accessories;
  final String complaint;
  final String deposit;
  final String serviceFee;
  final String warrantyDays;
  final bool isLoadingCustomers;

  ServiceFormState copyWith({
    CustomerModel? selectedCustomer,
    bool clearSelectedCustomer = false,
    List<CustomerModel>? customers,
    String? customerSearch,
    String? deviceName,
    String? deviceType,
    String? serialNumber,
    String? accessories,
    String? complaint,
    String? deposit,
    String? serviceFee,
    String? warrantyDays,
    bool? isLoadingCustomers,
  }) {
    return ServiceFormState(
      selectedCustomer: clearSelectedCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      customers: customers ?? this.customers,
      customerSearch: customerSearch ?? this.customerSearch,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      serialNumber: serialNumber ?? this.serialNumber,
      accessories: accessories ?? this.accessories,
      complaint: complaint ?? this.complaint,
      deposit: deposit ?? this.deposit,
      serviceFee: serviceFee ?? this.serviceFee,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      isLoadingCustomers: isLoadingCustomers ?? this.isLoadingCustomers,
    );
  }
}

final serviceFormProvider = NotifierProvider<ServiceFormNotifier, ServiceFormState>(
  ServiceFormNotifier.new,
);

class ServiceFormNotifier extends Notifier<ServiceFormState> {
  Timer? _debounce;

  @override
  ServiceFormState build() {
    ref.onDispose(() => _debounce?.cancel());
    Future.microtask(loadCustomers);
    return const ServiceFormState();
  }

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoadingCustomers: true);
    try {
      final repository = ref.read(customerRepositoryProvider);
      final response = await repository.getCustomers(page: 1, search: state.customerSearch);
      state = state.copyWith(
        customers: response.data,
        isLoadingCustomers: false,
        clearSelectedCustomer:
            state.selectedCustomer != null && !response.data.any((c) => c.id == state.selectedCustomer!.id),
      );
    } catch (_) {
      state = state.copyWith(isLoadingCustomers: false);
    }
  }

  void setCustomerSearch(String value) {
    state = state.copyWith(customerSearch: value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), loadCustomers);
  }

  void setCustomer(CustomerModel? customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void setDeviceName(String value) => state = state.copyWith(deviceName: value);
  void setDeviceType(String value) => state = state.copyWith(deviceType: value);
  void setSerialNumber(String value) => state = state.copyWith(serialNumber: value);
  void setAccessories(String value) => state = state.copyWith(accessories: value);
  void setComplaint(String value) => state = state.copyWith(complaint: value);
  void setDeposit(String value) => state = state.copyWith(deposit: value);
  void setServiceFee(String value) => state = state.copyWith(serviceFee: value);
  void setWarrantyDays(String value) => state = state.copyWith(warrantyDays: value);
}
