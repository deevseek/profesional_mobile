import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/product/data/models/product_model.dart';
import 'package:profesionalservis_mobile/features/product/data/repositories/product_repository.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_model.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_tracking_model.dart';
import 'package:profesionalservis_mobile/features/services/data/repositories/service_repository.dart';
import 'package:profesionalservis_mobile/features/services/domain/service_payloads.dart';

class ServiceListState {
  const ServiceListState({
    this.items = const [],
    this.search = '',
    this.status,
    this.currentPage = 1,
    this.hasNextPage = false,
    this.isLoadingMore = false,
  });

  final List<ServiceModel> items;
  final String search;
  final String? status;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoadingMore;

  ServiceListState copyWith({
    List<ServiceModel>? items,
    String? search,
    String? status,
    bool clearStatus = false,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoadingMore,
  }) {
    return ServiceListState(
      items: items ?? this.items,
      search: search ?? this.search,
      status: clearStatus ? null : (status ?? this.status),
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final serviceListProvider = AsyncNotifierProvider<ServiceListNotifier, ServiceListState>(
  ServiceListNotifier.new,
);

class ServiceListNotifier extends AsyncNotifier<ServiceListState> {
  Timer? _debounce;

  ServiceRepository get _repository => ref.read(serviceRepositoryProvider);

  @override
  Future<ServiceListState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    return _fetch(resetData: true, nextPage: 1, seed: const ServiceListState());
  }

  Future<void> refresh() async {
    final current = state.valueOrNull ?? const ServiceListState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(resetData: true, nextPage: 1, seed: current),
    );
  }

  void onSearchChanged(String value) {
    final current = state.valueOrNull ?? const ServiceListState();
    state = AsyncData(current.copyWith(search: value));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      await refresh();
    });
  }

  Future<void> setStatus(String? status) async {
    final current = state.valueOrNull ?? const ServiceListState();
    state = AsyncData(
      current.copyWith(status: status, clearStatus: status == null || status.isEmpty),
    );
    await refresh();
  }

  Future<void> fetchMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNextPage || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await AsyncValue.guard(
      () => _fetch(resetData: false, nextPage: current.currentPage + 1, seed: current),
    );

    result.whenData((value) {
      state = AsyncData(value.copyWith(isLoadingMore: false));
    });
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
    }
  }

  Future<ServiceListState> _fetch({
    required bool resetData,
    required int nextPage,
    required ServiceListState seed,
  }) async {
    final response = await _repository.getServices(
      page: nextPage,
      search: seed.search,
      status: seed.status,
    );

    return seed.copyWith(
      items: resetData ? response.data : [...seed.items, ...response.data],
      currentPage: response.currentPage ?? nextPage,
      hasNextPage: response.hasNextPage,
      isLoadingMore: false,
    );
  }
}

final serviceDetailProvider = AsyncNotifierProvider.family<ServiceDetailNotifier, ServiceModel, String>(
  ServiceDetailNotifier.new,
);

class ServiceDetailNotifier extends FamilyAsyncNotifier<ServiceModel, String> {
  ServiceRepository get _repository => ref.read(serviceRepositoryProvider);

  @override
  Future<ServiceModel> build(String arg) => _repository.getServiceDetail(arg);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getServiceDetail(arg));
  }


  Future<ServiceReceiptResponse> getReceipt() {
    return _repository.getServiceReceipt(arg);
  }

  Future<ServiceInvoiceResponse> getInvoice() {
    return _repository.getServiceInvoice(arg);
  }

  Future<bool> updateService(Map<String, dynamic> payload) async {
    final current = state.valueOrNull;
    if (current == null) return false;

    final updated = await AsyncValue.guard(() => _repository.updateService(arg, payload));
    if (updated.hasError) {
      state = AsyncError(updated.error!, updated.stackTrace!);
      return false;
    }

    state = AsyncData(updated.requireValue);
    return true;
  }

  Future<bool> updateServiceStatus(String status) async {
    final updated = await AsyncValue.guard(
      () => _repository.updateServiceStatus(id: arg, status: status),
    );
    if (updated.hasError) {
      state = AsyncError(updated.error!, updated.stackTrace!);
      return false;
    }

    state = AsyncData(updated.requireValue);
    return true;
  }

  Future<bool> addItem(AddServiceItemPayload payload) async {
    final result = await AsyncValue.guard(() => _repository.addServiceItem(arg, payload));
    if (result.hasError) {
      return false;
    }
    state = AsyncData(result.requireValue);
    return true;
  }

  Future<bool> removeItem(String itemId) async {
    final result = await AsyncValue.guard(() => _repository.deleteServiceItem(arg, itemId));
    if (result.hasError) {
      return false;
    }
    state = AsyncData(result.requireValue);
    return true;
  }

  Future<ServiceWhatsAppNotificationResponse?> notifyWhatsApp({
    String? template,
    String? message,
  }) async {
    final result = await AsyncValue.guard(
      () => _repository.notifyWhatsApp(id: arg, template: template, message: message),
    );

    if (result.hasError) {
      return null;
    }

    return result.requireValue;
  }
}

final createServiceProvider = AsyncNotifierProvider<CreateServiceNotifier, void>(
  CreateServiceNotifier.new,
);

class CreateServiceNotifier extends AsyncNotifier<void> {
  ServiceRepository get _repository => ref.read(serviceRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<ServiceModel?> submit(CreateServicePayload payload) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => _repository.createService(payload));
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return null;
    }

    state = const AsyncData(null);
    return result.requireValue;
  }
}

final productSearchProvider = FutureProvider.family<List<ProductModel>, String>((ref, query) async {
  final repository = ref.watch(productRepositoryProvider);
  final response = await repository.getProducts(page: 1, search: query);
  return response.data;
});

final serviceTrackingProvider = FutureProvider.family<ServiceTrackingModel, String>((ref, serviceId) {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.getServiceTracking(serviceId);
});
