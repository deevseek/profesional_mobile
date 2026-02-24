import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/core/error/global_error_handler.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
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
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await ref.read(authStateProvider.notifier).handleUnauthorized();
        }

        if (_shouldRetry(error)) {
          final retries = (error.requestOptions.extra['retry_count'] as int?) ?? 0;
          if (retries < 2) {
            await Future.delayed(Duration(milliseconds: 400 * (retries + 1)));
            final requestOptions = error.requestOptions;
            requestOptions.extra['retry_count'] = retries + 1;
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          }
          GlobalErrorHandler.showErrorSnackbar(
            'Koneksi internet tidak stabil. Data akan dimuat ulang saat jaringan kembali.',
          );
        } else if (error.type != DioExceptionType.badResponse) {
          GlobalErrorHandler.showErrorSnackbar('Terjadi kendala jaringan. Coba lagi.');
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});

bool _shouldRetry(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError) {
    return true;
  }

  return error.type == DioExceptionType.unknown && error.error is SocketException;
}
