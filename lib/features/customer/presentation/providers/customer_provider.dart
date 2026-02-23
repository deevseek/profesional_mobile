import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/customer/data/models/customer_model.dart';
import 'package:profesionalservis_mobile/features/customer/data/repositories/customer_repository.dart';

final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>((ref) {
  final notifier = CustomerNotifier(ref.watch(customerRepositoryProvider));
  notifier.fetchInitial();
  ref.onDispose(notifier.dispose);
  return notifier;
});

class CustomerState {
  const CustomerState({
    this.items = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasNextPage = false,
    this.currentPage = 1,
    this.errorMessage,
  });

  final List<CustomerModel> items;
  final String searchQuery;
  final bool isLoading;
  final bool isSubmitting;
  final bool hasNextPage;
  final int currentPage;
  final String? errorMessage;

  CustomerState copyWith({
    List<CustomerModel>? items,
    String? searchQuery,
    bool? isLoading,
    bool? isSubmitting,
    bool? hasNextPage,
    int? currentPage,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CustomerState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  CustomerNotifier(this._repository) : super(const CustomerState());

  final CustomerRepository _repository;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchInitial() async {
    await _fetch(page: 1, resetData: true);
  }

  Future<void> refresh() async {
    await _fetch(page: 1, resetData: true);
  }

  Future<void> fetchMore() async {
    if (state.isLoading || !state.hasNextPage) {
      return;
    }

    await _fetch(page: state.currentPage + 1, resetData: false);
  }

  Future<void> _fetch({required int page, required bool resetData}) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final response = await _repository.getCustomers(
        page: page,
        search: state.searchQuery,
      );

      final nextItems = resetData ? response.data : [...state.items, ...response.data];

      state = state.copyWith(
        items: nextItems,
        isLoading: false,
        hasNextPage: response.hasNextPage,
        currentPage: response.currentPage ?? page,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat pelanggan. Silakan coba lagi.',
      );
    }
  }

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), fetchInitial);
  }

  Future<bool> addCustomer(CustomerModel customer) async {
    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      await _repository.addCustomer(customer);
      state = state.copyWith(isSubmitting: false);
      await fetchInitial();
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal menambahkan pelanggan.',
      );
      return false;
    }
  }

  Future<bool> updateCustomer({
    required String id,
    required CustomerModel customer,
  }) async {
    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      await _repository.editCustomer(id: id, customer: customer);
      state = state.copyWith(isSubmitting: false);
      await fetchInitial();
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal mengubah pelanggan.',
      );
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      await _repository.deleteCustomer(id);
      state = state.copyWith(isSubmitting: false);
      await fetchInitial();
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal menghapus pelanggan.',
      );
      return false;
    }
  }
}
