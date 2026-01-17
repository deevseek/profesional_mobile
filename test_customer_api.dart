import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test script untuk debug customer API issue
/// 
/// Tujuan:
/// 1. Check apakah token ada di SharedPreferences
/// 2. Test direct API call ke /customers
/// 3. Lihat exact response dari server

Future<void> main() async {
  print('🔍 [TEST] Starting Customer API Debug...\n');

  // Check token in SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  
  print('🔑 [TOKEN]');
  if (token != null && token.isNotEmpty) {
    print('   ✅ Token found: ${token.substring(0, 20)}...');
  } else {
    print('   ❌ NO TOKEN FOUND - User must login first!');
  }
  print('');

  // Test API call
  print('🌐 [API TEST]');
  final dio = Dio(BaseOptions(
    baseUrl: 'https://sciencecomputer.profesionalservis.my.id/api/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  try {
    // Test without token
    print('   Testing /customers WITHOUT token...');
    final response1 = await dio.get('/customers');
    print('   ✅ Response (200): ${response1.data}');
  } catch (e) {
    print('   ❌ Error (without token): ${e.toString().substring(0, 100)}');
  }
  print('');

  if (token != null && token.isNotEmpty) {
    try {
      // Test with token
      print('   Testing /customers WITH token...');
      final response2 = await dio.get(
        '/customers',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('   ✅ Response (200): ${response2.data}');
    } catch (e) {
      print('   ❌ Error (with token): ${e.toString().substring(0, 100)}');
    }
  }

  print('\n📋 [CONCLUSION]');
  print('   If "NO TOKEN FOUND" - User must login');
  print('   If token exists but error - Check token validity');
  print('   If success - API working fine');
}
