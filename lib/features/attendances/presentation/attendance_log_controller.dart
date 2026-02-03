import 'package:flutter/foundation.dart';

import '../data/attendance_log_repository_impl.dart';
import '../domain/attendance_log_model.dart';
import '../domain/attendance_log_repository.dart';

class AttendanceLogController extends ChangeNotifier {
  AttendanceLogController({AttendanceLogRepository? repository})
      : _repository = repository ?? AttendanceLogRepositoryImpl();

  final AttendanceLogRepository _repository;

  bool _loading = false;
  String? _errorMessage;
  List<AttendanceLog> _attendanceLogs = const [];
  AttendanceLogPaginationMeta? _meta;
  AttendanceLogPaginationLinks? _links;
  String _userIdQuery = '';
  String _typeQuery = '';
  String _deviceInfoQuery = '';
  int _page = 1;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  List<AttendanceLog> get attendanceLogs => _attendanceLogs;
  AttendanceLogPaginationMeta? get meta => _meta;
  AttendanceLogPaginationLinks? get links => _links;
  String get userIdQuery => _userIdQuery;
  String get typeQuery => _typeQuery;
  String get deviceInfoQuery => _deviceInfoQuery;
  int get page => _page;

  Future<void> loadAttendanceLogs({
    String? userId,
    String? type,
    String? deviceInfo,
    int page = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _userIdQuery = userId ?? _userIdQuery;
    _typeQuery = type ?? _typeQuery;
    _deviceInfoQuery = deviceInfo ?? _deviceInfoQuery;
    _page = page;
    try {
      final result = await _repository.getAttendanceLogs(
        userId: _userIdQuery.isEmpty ? null : _userIdQuery,
        type: _typeQuery.isEmpty ? null : _typeQuery,
        deviceInfo: _deviceInfoQuery.isEmpty ? null : _deviceInfoQuery,
        page: _page,
      );
      _attendanceLogs = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load attendance logs. Please try again.';
      _attendanceLogs = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_loading == value) {
      return;
    }
    _loading = value;
    notifyListeners();
  }
}
