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
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return _ensureMap(response.data, message: 'Invalid login response');
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
}
