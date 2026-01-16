import 'package:dio/dio.dart';

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
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, handler) {
        handler.reject(_mapDioError(error));
      },
    ));
  }

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
    if (statusCode == null) {
      return error.copyWith(
        error: ApiException('Network error', statusCode: statusCode),
      );
    }

    switch (statusCode) {
      case 401:
        return error.copyWith(
          error: UnauthorizedException(statusCode: statusCode),
        );
      case 422:
        return error.copyWith(
          error: ValidationException(statusCode: statusCode),
        );
      case 404:
        return error.copyWith(
          error: NotFoundException(statusCode: statusCode),
        );
      case 502:
        return error.copyWith(
          error: ServiceUnavailableException(statusCode: statusCode),
        );
      default:
        return error.copyWith(
          error: ApiException('Request failed', statusCode: statusCode),
        );
    }
  }
}
