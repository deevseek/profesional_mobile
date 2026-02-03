import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/attendance_log_model.dart';

class AttendanceLogRemoteDataSource {
  AttendanceLogRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<AttendanceLogPage> fetchAttendanceLogs({
    String? userId,
    String? type,
    String? deviceInfo,
    int page = 1,
    int? perPage,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/attendance-logs',
      queryParameters: {
        if (userId != null && userId.trim().isNotEmpty) 'user_id': userId.trim(),
        if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
        if (deviceInfo != null && deviceInfo.trim().isNotEmpty)
          'device_info': deviceInfo.trim(),
        'page': page,
        if (perPage != null) 'per_page': perPage,
      },
    );

    return AttendanceLogPage.fromJson(
      _ensureMap(response.data, message: 'Invalid attendance logs response'),
    );
  }

  Future<AttendanceLog> fetchAttendanceLog(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/attendance-logs/$id');
    final payload = _ensureMap(response.data, message: 'Invalid attendance log response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return AttendanceLog.fromJson(data);
    }

    return AttendanceLog.fromJson(payload);
  }

  Future<AttendanceLog> createAttendanceLog(AttendanceLogRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/attendance-logs',
      data: request.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid attendance log response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return AttendanceLog.fromJson(data);
    }

    return AttendanceLog.fromJson(payload);
  }

  Future<AttendanceLog> updateAttendanceLog(String id, AttendanceLogRequest request) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/attendance-logs/$id',
      data: request.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid attendance log response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return AttendanceLog.fromJson(data);
    }

    return AttendanceLog.fromJson(payload);
  }

  Future<void> deleteAttendanceLog(String id) async {
    await _client.delete<void>('/attendance-logs/$id');
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
