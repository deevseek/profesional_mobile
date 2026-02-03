import '../domain/attendance_model.dart';
import '../domain/attendance_repository.dart';
import 'attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl({AttendanceRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AttendanceRemoteDataSource();

  final AttendanceRemoteDataSource _remoteDataSource;

  @override
  Future<AttendancePage> getAttendances({
    String? employeeId,
    DateTime? attendanceDate,
    String? status,
    String? method,
    int page = 1,
    int? perPage,
  }) {
    return _remoteDataSource.fetchAttendances(
      employeeId: employeeId,
      attendanceDate: attendanceDate,
      status: status,
      method: method,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<Attendance> getAttendance(String id) {
    return _remoteDataSource.fetchAttendance(id);
  }

  @override
  Future<Attendance> createAttendance(AttendanceRequest request) {
    return _remoteDataSource.createAttendance(request);
  }

  @override
  Future<Attendance> updateAttendance(String id, AttendanceUpdateRequest request) {
    return _remoteDataSource.updateAttendance(id, request);
  }

  @override
  Future<void> deleteAttendance(String id) {
    return _remoteDataSource.deleteAttendance(id);
  }
}
