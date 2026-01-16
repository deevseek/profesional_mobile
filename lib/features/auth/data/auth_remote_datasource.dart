import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final payload =
          _ensureMap(response.data, message: 'Invalid login response');
      final token = payload['token'];
      final user = payload['user'];

      if (token is! String || token.isEmpty) {
        throw ApiException('Authentication token missing');
      }

      final userMap =
          _ensureMap(user, message: 'Invalid user response from server');

      return {
        'token': token,
        'user': userMap,
      };
    } on DioException catch (error) {
      final message = _extractDioMessage(error) ??
          (error.error is ApiException
              ? (error.error as ApiException).message
              : 'Unable to login');
      throw ApiException(message, statusCode: error.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _client.get<Map<String, dynamic>>('/auth/me');
    return _ensureMap(response.data, message: 'Invalid profile response');
  }

  Future<void> logout() async {
    await _client.post<void>('/auth/logout');
  }

  Map<String, dynamic> _ensureMap(
    dynamic data, {
    required String message,
  }) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.map((key, value) => MapEntry('$key', value));
    }

    throw ApiException(message);
  }

  String? _extractDioMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }

      final errors = data['errors'];
      if (errors is Map) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          final entry = first.first;
          if (entry is String && entry.trim().isNotEmpty) {
            return entry.trim();
          }
        }
        if (first is String && first.trim().isNotEmpty) {
          return first.trim();
        }
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return null;
  }
}
