import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../errors/api_exception.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient({
    Dio? dio,
    AuthInterceptor? authInterceptor,
  })  : _dio = dio ?? Dio(),
        _authInterceptor = authInterceptor ?? AuthInterceptor() {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );

    _dio.interceptors.add(_authInterceptor);
    
    // Add logging interceptor for debugging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('🔵 [API REQUEST] ${options.method} ${options.path}');
            if (options.queryParameters.isNotEmpty) {
              print('   Query Params: ${options.queryParameters}');
            }
            if (options.data != null) {
              print('   Body: ${options.data}');
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('🟢 [API RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
            print('   Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (kDebugMode) {
            print('🔴 [API ERROR] ${error.response?.statusCode} ${error.requestOptions.path}');
            print('   Error: ${error.message}');
            print('   Data: ${error.response?.data}');
          }
          if (error.response?.statusCode == 401) {
            await _clearAuthToken();
          }
          handler.reject(_mapDioError(error));
        },
      ),
    );
  }

  static const _tokenKey = 'auth_token';

  final Dio _dio;
  final AuthInterceptor _authInterceptor;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  DioException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    String? serverMessage;

    // Extract error message from server response
    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message']?.toString() ??
          responseData['error']?.toString();
    }

    if (statusCode == null) {
      return error.copyWith(
        error: ApiException(
          serverMessage ?? 'Network error',
          statusCode: statusCode,
        ),
      );
    }

    switch (statusCode) {
      case 401:
        final message = serverMessage ?? 
            'Unauthorized - Please login again. Token may be expired.';
        if (kDebugMode) {
          print('🔴 [401 AUTH ERROR] $message');
        }
        return error.copyWith(
          error: UnauthorizedException(
            message: message,
            statusCode: statusCode,
          ),
        );
      case 404:
        return error.copyWith(
          error: NotFoundException(
            message: serverMessage ?? 'Resource not found',
            statusCode: statusCode,
          ),
        );
      case 422:
        return error.copyWith(
          error: ValidationException(
            message: serverMessage ?? 'Validation error',
            statusCode: statusCode,
          ),
        );
      case 500:
      case 502:
      case 503:
        return error.copyWith(
          error: ServiceUnavailableException(
            message: serverMessage ?? 'Service unavailable',
            statusCode: statusCode,
          ),
        );
      default:
        return error.copyWith(
          error: ApiException(
            serverMessage ?? 'Request failed',
            statusCode: statusCode,
          ),
        );
    }
  }

  Future<void> _clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
