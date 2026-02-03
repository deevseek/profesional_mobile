import 'attendance_model.dart';

abstract class AttendanceRepository {
  Future<AttendancePage> getAttendances({
    String? employeeId,
    DateTime? attendanceDate,
    String? status,
    String? method,
    int page = 1,
    int? perPage,
  });

  Future<Attendance> getAttendance(String id);

  Future<Attendance> createAttendance(AttendanceRequest request);

  Future<Attendance> updateAttendance(String id, AttendanceUpdateRequest request);

  Future<void> deleteAttendance(String id);
}
