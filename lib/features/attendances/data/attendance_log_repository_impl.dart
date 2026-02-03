import '../domain/attendance_log_model.dart';
import '../domain/attendance_log_repository.dart';
import 'attendance_log_remote_datasource.dart';

class AttendanceLogRepositoryImpl implements AttendanceLogRepository {
  AttendanceLogRepositoryImpl({AttendanceLogRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AttendanceLogRemoteDataSource();

  final AttendanceLogRemoteDataSource _remoteDataSource;

  @override
  Future<AttendanceLogPage> getAttendanceLogs({
    String? userId,
    String? type,
    String? deviceInfo,
    int page = 1,
    int? perPage,
  }) {
    return _remoteDataSource.fetchAttendanceLogs(
      userId: userId,
      type: type,
      deviceInfo: deviceInfo,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<AttendanceLog> getAttendanceLog(String id) {
    return _remoteDataSource.fetchAttendanceLog(id);
  }

  @override
  Future<AttendanceLog> createAttendanceLog(AttendanceLogRequest request) {
    return _remoteDataSource.createAttendanceLog(request);
  }

  @override
  Future<AttendanceLog> updateAttendanceLog(String id, AttendanceLogRequest request) {
    return _remoteDataSource.updateAttendanceLog(id, request);
  }

  @override
  Future<void> deleteAttendanceLog(String id) {
    return _remoteDataSource.deleteAttendanceLog(id);
  }
}
