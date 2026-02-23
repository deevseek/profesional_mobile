import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(dioProvider));
});

class AttendanceRepository {
  const AttendanceRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>?> getTodayAttendanceStatus() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/attendances/today');
      final body = response.data;
      final data = body?['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (body is Map<String, dynamic>) {
        return body;
      }
      return null;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> submitAttendance({
    required int shiftNumber,
    required double latitude,
    required double longitude,
    required String faceRecognitionSnapshot,
    required String attendanceType,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/attendances',
      data: {
        'shift_number': shiftNumber,
        'location_latitude': latitude,
        'location_longitude': longitude,
        'face_recognition_snapshot': faceRecognitionSnapshot,
        'attendance_type': attendanceType,
      },
    );
  }
}
