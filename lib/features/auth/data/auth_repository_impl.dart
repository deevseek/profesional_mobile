import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/api_exception.dart';
import '../domain/auth_repository.dart';
import 'auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    SharedPreferences? sharedPreferences,
  })  : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
        _sharedPreferences = sharedPreferences;

  static const _tokenKey = 'auth_token';

  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences? _sharedPreferences;

  @override
  Future<AuthUser?> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    final token = _extractToken(response);
    if (token == null || token.isEmpty) {
      throw ApiException('Authentication token missing');
    }

    final prefs = await _prefs();
    await prefs.setString(_tokenKey, token);

    final userJson = _extractUserMap(response);
    if (userJson != null) {
      return AuthUser.fromJson(userJson);
    }

    return getCurrentUser();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final prefs = await _prefs();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _remoteDataSource.me();
      final userJson = _extractUserMap(response) ?? response;
      return AuthUser.fromJson(userJson);
    } on DioException catch (error) {
      if (_isUnauthorized(error)) {
        await prefs.remove(_tokenKey);
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } on DioException catch (error) {
      if (!_isUnauthorized(error)) {
        rethrow;
      }
    } finally {
      final prefs = await _prefs();
      await prefs.remove(_tokenKey);
    }
  }

  Future<SharedPreferences> _prefs() async {
    return _sharedPreferences ?? SharedPreferences.getInstance();
  }

  bool _isUnauthorized(DioException error) {
    return error.error is UnauthorizedException || error.response?.statusCode == 401;
  }

  String? _extractToken(Map<String, dynamic> payload) {
    final directToken = payload['token'] ??
        payload['access_token'] ??
        payload['auth_token'] ??
        payload['jwt'];
    if (directToken is String) {
      return directToken;
    }

    final nested = payload['data'];
    if (nested is Map<String, dynamic>) {
      return _extractToken(nested);
    }

    return null;
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> payload) {
    final candidate = payload['user'] ?? payload['profile'];
    if (candidate is Map<String, dynamic>) {
      return candidate;
    }

    final nested = payload['data'];
    if (nested is Map<String, dynamic>) {
      return _extractUserMap(nested) ?? nested;
    }

    return null;
  }
}
