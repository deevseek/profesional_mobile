import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({SharedPreferences? sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences? _sharedPreferences;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}
