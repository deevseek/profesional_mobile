import 'attendance_log_model.dart';

abstract class AttendanceLogRepository {
  Future<AttendanceLogPage> getAttendanceLogs({
    String? userId,
    String? type,
    String? deviceInfo,
    int page = 1,
    int? perPage,
  });

  Future<AttendanceLog> getAttendanceLog(String id);

  Future<AttendanceLog> createAttendanceLog(AttendanceLogRequest request);

  Future<AttendanceLog> updateAttendanceLog(String id, AttendanceLogRequest request);

  Future<void> deleteAttendanceLog(String id);
}
