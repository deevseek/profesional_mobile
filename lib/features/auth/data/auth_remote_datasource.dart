import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
      if (kDebugMode) {
        print('🔵 [AUTH LOGIN] Attempting login with email: $email');
      }
      
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (kDebugMode) {
        print('🟢 [AUTH LOGIN] Response received: ${response.data}');
      }

      final payload =
          _ensureMap(response.data, message: 'Invalid login response');
      
      // Extract token - try multiple possible keys
      final token = payload['token'] ??
          payload['access_token'] ??
          payload['auth_token'] ??
          payload['jwt'] ??
          (payload['data'] is Map ? payload['data']['token'] : null);
      
      // Extract user - try multiple possible keys  
      final user = payload['user'] ??
          payload['profile'] ??
          (payload['data'] is Map ? payload['data']['user'] : null) ??
          payload['data'];

      if (kDebugMode) {
        print('🟢 [AUTH LOGIN] Token: ${token?.substring(0, 10)}... User: ${user is Map ? user['id'] : 'null'}');
      }

      if (token is! String || token.isEmpty) {
        throw ApiException('Authentication token missing from server response. Got: ${payload.keys}');
      }

      // Validate user
      if (user == null) {
        throw ApiException('User data missing from server response. Got: ${payload.keys}');
      }

      final userMap = user is Map<String, dynamic>
          ? user
          : _ensureMap(user, message: 'Invalid user response from server');

      return {
        'token': token,
        'user': userMap,
      };
    } on DioException catch (error) {
      if (kDebugMode) {
        print('🔴 [AUTH LOGIN DIO ERROR] ${error.message}');
        print('🔴 [AUTH LOGIN DIO ERROR] Status: ${error.response?.statusCode}');
        print('🔴 [AUTH LOGIN DIO ERROR] Response: ${error.response?.data}');
      }
      final message = _extractDioMessage(error) ??
          (error.error is ApiException
              ? (error.error as ApiException).message
              : 'Unable to login');
      throw ApiException(message, statusCode: error.response?.statusCode);
    } catch (error) {
      if (kDebugMode) {
        print('🔴 [AUTH LOGIN ERROR] $error');
      }
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException(error.toString());
    }
  }

  Future<Map<String, dynamic>> me() async {
    try {
      if (kDebugMode) {
        print('🔵 [AUTH] Fetching /auth/me');
      }
      
      final response = await _client.get<Map<String, dynamic>>('/auth/me');
      
      if (kDebugMode) {
        print('🟢 [AUTH] /auth/me response: ${response.data}');
      }
      
      return _ensureMap(response.data, message: 'Invalid profile response');
    } on DioException catch (error) {
      if (kDebugMode) {
        print('🔴 [AUTH] /auth/me error - Status: ${error.response?.statusCode}, Message: ${error.message}');
      }
      rethrow;
    }
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
    if (kDebugMode) {
      print('🔴 [AUTH ERROR] Status: ${error.response?.statusCode}');
      print('🔴 [AUTH ERROR] Response: $data');
    }
    
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }

      final errors = data['errors'];
      if (errors is Map) {
        final first = errors.values.firstOrNull;
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
