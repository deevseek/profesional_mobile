import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/tenant/tenant_resolver_service.dart';
import 'package:profesionalservis_mobile/tenant/tenant_storage.dart';

final tenantStateProvider =
    StateNotifierProvider<TenantStateNotifier, TenantState>((ref) {
      final notifier = TenantStateNotifier(
        resolver: ref.watch(tenantResolverServiceProvider),
        storage: ref.watch(tenantStorageProvider),
      );
      notifier.bootstrap();
      return notifier;
    });

class TenantState {
  const TenantState({
    this.tenantCode,
    this.baseUrl,
    this.errorMessage,
    this.isBootstrapping = false,
    this.isSubmitting = false,
  });

  final String? tenantCode;
  final String? baseUrl;
  final String? errorMessage;
  final bool isBootstrapping;
  final bool isSubmitting;

  bool get hasTenant =>
      baseUrl != null && baseUrl!.isNotEmpty && tenantCode != null && tenantCode!.isNotEmpty;

  TenantState copyWith({
    String? tenantCode,
    String? baseUrl,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isBootstrapping,
    bool? isSubmitting,
  }) {
    return TenantState(
      tenantCode: tenantCode ?? this.tenantCode,
      baseUrl: baseUrl ?? this.baseUrl,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class TenantStateNotifier extends StateNotifier<TenantState> {
  TenantStateNotifier({
    required TenantResolverService resolver,
    required TenantStorage storage,
  }) : _resolver = resolver,
       _storage = storage,
       super(const TenantState(isBootstrapping: true));

  final TenantResolverService _resolver;
  final TenantStorage _storage;

  Future<void> bootstrap() async {
    state = state.copyWith(isBootstrapping: true, clearErrorMessage: true);

    final savedTenantCode = await _storage.readTenantCode();
    final savedBaseUrl = await _storage.readTenantBaseUrl();

    state = state.copyWith(
      tenantCode: savedTenantCode,
      baseUrl: savedBaseUrl,
      isBootstrapping: false,
    );
  }

  Future<bool> resolveTenant(String tenantCode) async {
    final sanitizedCode = tenantCode.trim();

    if (sanitizedCode.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Kode tenant wajib diisi.',
        isSubmitting: false,
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);

    try {
      final apiUrl = await _resolver.resolveTenantApiUrl(sanitizedCode);

      await _storage.saveTenant(tenantCode: sanitizedCode, baseUrl: apiUrl);
      state = state.copyWith(
        tenantCode: sanitizedCode,
        baseUrl: apiUrl,
        isSubmitting: false,
        clearErrorMessage: true,
      );
      return true;
    } on DioException catch (_) {
      state = state.copyWith(
        errorMessage: 'Tenant tidak ditemukan atau server tidak merespons.',
        isSubmitting: false,
      );
      return false;
    } on TenantResolveException catch (error) {
      state = state.copyWith(
        errorMessage: error.message,
        isSubmitting: false,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Terjadi kesalahan saat memproses tenant.',
        isSubmitting: false,
      );
      return false;
    }
  }

  Future<void> clearTenant() async {
    await _storage.clearTenant();
    state = const TenantState();
  }
}
