import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/storage/secure_storage_service.dart';
import 'package:profesionalservis_mobile/tenant/tenant_state_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final tenantState = ref.watch(tenantStateProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: tenantState.baseUrl ?? 'https://api.example.com',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ),
  );

  return dio;
});
