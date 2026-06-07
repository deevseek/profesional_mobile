import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/core/error/global_error_handler.dart';
import 'package:profesionalservis_mobile/core/network/api_exception.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/storage/secure_storage_service.dart';
import 'package:profesionalservis_mobile/tenant/tenant_state_provider.dart';

final dioProvider = Provider<Dio>((ref) => ref.watch(apiClientProvider).dio);

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final tenantState = ref.watch(tenantStateProvider);
  return ApiClient(ref: ref, storage: storage, baseUrl: tenantState.baseUrl);
});

class ApiClient {
  ApiClient({
    required Ref ref,
    required SecureStorageService storage,
    required String? baseUrl,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: _normalizeBaseUrl(baseUrl),
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
            headers: const {'Content-Type': Headers.jsonContentType},
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = options.contentType ?? Headers.jsonContentType;
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await ref.read(authStateProvider.notifier).handleUnauthorized();
          }

          if (_shouldRetry(error)) {
            final retries = (error.requestOptions.extra['retry_count'] as int?) ?? 0;
            if (retries < 1) {
              await Future.delayed(Duration(milliseconds: 450 * (retries + 1)));
              final requestOptions = error.requestOptions;
              requestOptions.extra['retry_count'] = retries + 1;
              final response = await dio.fetch<dynamic>(requestOptions);
              return handler.resolve(response);
            }
            GlobalErrorHandler.showErrorSnackbar(ApiException.fromDio(error).message);
          } else if (error.type != DioExceptionType.badResponse) {
            GlobalErrorHandler.showErrorSnackbar(ApiException.fromDio(error).message);
          }

          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;

  static String _normalizeBaseUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'https://profesionalservis.my.id/api/v1';
    return text.endsWith('/') ? text.substring(0, text.length - 1) : text;
  }
}

bool _shouldRetry(DioException error) {
  if (error.requestOptions.method.toUpperCase() != 'GET') return false;
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError) {
    return true;
  }

  return error.type == DioExceptionType.unknown && error.error is SocketException;
}
