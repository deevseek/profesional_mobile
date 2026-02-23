import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tenantResolverServiceProvider = Provider<TenantResolverService>((ref) {
  return TenantResolverService();
});

class TenantResolverService {
  TenantResolverService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://profesionalservis.my.id',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
              ),
            );

  final Dio _dio;

  Future<String> resolveTenantApiUrl(String tenantCode) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/resolve-tenant',
      data: {'tenant': tenantCode},
    );

    final data = response.data;
    final apiUrl = _extractApiUrl(data);

    if (apiUrl == null || apiUrl.isEmpty) {
      throw const TenantResolveException('Tenant tidak ditemukan.');
    }

    return apiUrl;
  }

  String? _extractApiUrl(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }

    final directUrl = data['api_url'] as String?;
    if (directUrl != null && directUrl.isNotEmpty) {
      return directUrl;
    }

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData['api_url'] as String?;
    }

    return null;
  }
}

class TenantResolveException implements Exception {
  const TenantResolveException(this.message);

  final String message;

  @override
  String toString() => message;
}
