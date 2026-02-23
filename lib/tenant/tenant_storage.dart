import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tenantStorageProvider = Provider<TenantStorage>((ref) {
  return const TenantStorage();
});

class TenantStorage {
  const TenantStorage();

  static const _tenantCodeKey = 'tenant_code';
  static const _tenantBaseUrlKey = 'tenant_base_url';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveTenant({
    required String tenantCode,
    required String baseUrl,
  }) async {
    await _storage.write(key: _tenantCodeKey, value: tenantCode);
    await _storage.write(key: _tenantBaseUrlKey, value: baseUrl);
  }

  Future<String?> readTenantCode() async {
    return _storage.read(key: _tenantCodeKey);
  }

  Future<String?> readTenantBaseUrl() async {
    return _storage.read(key: _tenantBaseUrlKey);
  }

  Future<void> clearTenant() async {
    await _storage.delete(key: _tenantCodeKey);
    await _storage.delete(key: _tenantBaseUrlKey);
  }
}
