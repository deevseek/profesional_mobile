import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/attendance_model.dart';

class AttendanceRemoteDataSource {
  AttendanceRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<AttendancePage> fetchAttendances({
    String? employeeId,
    DateTime? attendanceDate,
    String? status,
    String? method,
    int page = 1,
    int? perPage,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/attendances',
      queryParameters: {
        if (employeeId != null && employeeId.trim().isNotEmpty)
          'employee_id': employeeId.trim(),
        if (attendanceDate != null) 'attendance_date': _formatDate(attendanceDate),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        if (method != null && method.trim().isNotEmpty) 'method': method.trim(),
        'page': page,
        if (perPage != null) 'per_page': perPage,
      },
    );

    return AttendancePage.fromJson(
      _ensureMap(response.data, message: 'Invalid attendances response'),
    );
  }

  Future<Attendance> fetchAttendance(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/attendances/$id');
    final payload = _ensureMap(response.data, message: 'Invalid attendance response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Attendance.fromJson(data);
    }

    return Attendance.fromJson(payload);
  }

  Future<Attendance> createAttendance(AttendanceRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/attendances',
      data: request.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid attendance response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Attendance.fromJson(data);
    }

    return Attendance.fromJson(payload);
  }

  Future<Attendance> updateAttendance(String id, AttendanceUpdateRequest request) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/attendances/$id',
      data: request.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid attendance response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Attendance.fromJson(data);
    }

    return Attendance.fromJson(payload);
  }

  Future<void> deleteAttendance(String id) async {
    await _client.delete<void>('/attendances/$id');
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

String _formatDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
