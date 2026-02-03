import 'package:flutter/foundation.dart';

import '../data/attendance_repository_impl.dart';
import '../domain/attendance_model.dart';
import '../domain/attendance_repository.dart';

class AttendanceController extends ChangeNotifier {
  AttendanceController({AttendanceRepository? repository})
      : _repository = repository ?? AttendanceRepositoryImpl();

  final AttendanceRepository _repository;

  bool _loading = false;
  String? _errorMessage;
  List<Attendance> _attendances = const [];
  AttendancePaginationMeta? _meta;
  AttendancePaginationLinks? _links;
  String _employeeIdQuery = '';
  String _statusQuery = '';
  String _methodQuery = '';
  DateTime? _attendanceDate;
  int _page = 1;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  List<Attendance> get attendances => _attendances;
  AttendancePaginationMeta? get meta => _meta;
  AttendancePaginationLinks? get links => _links;
  String get employeeIdQuery => _employeeIdQuery;
  String get statusQuery => _statusQuery;
  String get methodQuery => _methodQuery;
  DateTime? get attendanceDate => _attendanceDate;
  int get page => _page;

  Future<void> loadAttendances({
    String? employeeId,
    String? status,
    String? method,
    DateTime? attendanceDate,
    int page = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _employeeIdQuery = employeeId ?? _employeeIdQuery;
    _statusQuery = status ?? _statusQuery;
    _methodQuery = method ?? _methodQuery;
    _attendanceDate = attendanceDate ?? _attendanceDate;
    _page = page;
    try {
      final result = await _repository.getAttendances(
        employeeId: _employeeIdQuery.isEmpty ? null : _employeeIdQuery,
        status: _statusQuery.isEmpty ? null : _statusQuery,
        method: _methodQuery.isEmpty ? null : _methodQuery,
        attendanceDate: _attendanceDate,
        page: _page,
      );
      _attendances = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load attendances. Please try again.';
      _attendances = const [];
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
