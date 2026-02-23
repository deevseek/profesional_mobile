import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/auth/data/models/login_request.dart';
import 'package:profesionalservis_mobile/features/auth/data/models/login_response.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Response login kosong.');
    }

    return LoginResponse.fromJson(data);
  }
}
