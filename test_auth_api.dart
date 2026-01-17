import 'package:profesional_service/core/network/dio_client.dart';

Future<void> testAuthEndpoint() async {
  final client = DioClient();

  try {
    print('🔵 Testing auth/login endpoint...');
    
    final response = await client.post(
      'auth/login',
      data: {
        'email': 'test@example.com',
        'password': 'password',
      },
    );

    print('✅ Success! Status: ${response.statusCode}');
    print('📦 Response: ${response.data}');
  } catch (e) {
    print('❌ Error: $e');
  }
}

void main() async {
  await testAuthEndpoint();
}
