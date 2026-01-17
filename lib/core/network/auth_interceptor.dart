import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({SharedPreferences? sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences? _sharedPreferences;
  static const String _tokenKey = 'auth_token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Always get fresh SharedPreferences to ensure latest token
      SharedPreferences prefs;
      if (_sharedPreferences != null) {
        prefs = _sharedPreferences!;
        if (kDebugMode) {
          print('📦 [AUTH INTERCEPTOR] Using injected SharedPreferences');
        }
      } else {
        prefs = await SharedPreferences.getInstance();
        if (kDebugMode) {
          print('📦 [AUTH INTERCEPTOR] Got fresh SharedPreferences');
        }
      }

      final token = prefs.getString(_tokenKey);

      if (kDebugMode) {
        print('🔑 [AUTH INTERCEPTOR] PATH: ${options.path}');
        print('🔑 [AUTH INTERCEPTOR] Token in storage: ${token != null ? 'YES (${token.length} chars)' : 'NO'}');
      }

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        if (kDebugMode) {
          print('✅ [AUTH INTERCEPTOR] Authorization header set: Bearer ${token.substring(0, 20)}...');
        }
      } else {
        if (kDebugMode) {
          print('⚠️  [AUTH INTERCEPTOR] No token found - request sent without Authorization');
        }
      }

      if (kDebugMode) {
        print('🔑 [AUTH INTERCEPTOR] Request headers: ${options.headers}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 [AUTH INTERCEPTOR ERROR] Exception: $e');
        print('🔴 [AUTH INTERCEPTOR ERROR] Stack: ${StackTrace.current}');
      }
    }

    handler.next(options);
  }
}

