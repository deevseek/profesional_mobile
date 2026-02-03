import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/attendance_repository_impl.dart';
import '../domain/attendance_model.dart';
import '../domain/attendance_repository.dart';

class AttendanceController extends ChangeNotifier {
  AttendanceController({AttendanceRepository? repository})
      : _repository = repository ?? AttendanceRepositoryImpl();

  final AttendanceRepository _repository;

  bool _loading = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<Attendance> _attendances = const [];
  AttendancePaginationMeta? _meta;
  AttendancePaginationLinks? _links;
  String _employeeIdQuery = '';
  String _statusQuery = '';
  String _methodQuery = '';
  DateTime? _attendanceDate;
  int _page = 1;
  Attendance? _attendance;
  Map<String, List<String>> _fieldErrors = const {};

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Attendance> get attendances => _attendances;
  AttendancePaginationMeta? get meta => _meta;
  AttendancePaginationLinks? get links => _links;
  String get employeeIdQuery => _employeeIdQuery;
  String get statusQuery => _statusQuery;
  String get methodQuery => _methodQuery;
  DateTime? get attendanceDate => _attendanceDate;
  int get page => _page;
  Attendance? get attendance => _attendance;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

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

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    notifyListeners();
  }

  Future<bool> createAttendance(AttendanceRequest request) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final created = await _repository.createAttendance(request);
      _attendance = created;
      _successMessage = 'Attendance submitted successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to submit attendance.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  void _setLoading(bool value) {
    if (_loading == value) {
      return;
    }
    _loading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    if (_submitting == value) {
      return;
    }
    _submitting = value;
    notifyListeners();
  }

  void _handleError(Object error, {required String fallbackMessage}) {
    if (error is DioException) {
      final message = _extractMessage(error) ?? fallbackMessage;
      _errorMessage = message;
      if (_isValidationError(error)) {
        _fieldErrors = _extractFieldErrors(error);
      }
      return;
    }

    if (error is ValidationException) {
      _errorMessage = error.message;
      return;
    }

    _errorMessage = fallbackMessage;
  }

  bool _isValidationError(DioException error) {
    return error.error is ValidationException || error.response?.statusCode == 422;
  }

  String? _extractMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message != null) {
        return message.toString();
      }
    }
    final apiError = error.error;
    if (apiError is ApiException) {
      return apiError.message;
    }
    return null;
  }

  Map<String, List<String>> _extractFieldErrors(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map) {
        return errors.map((key, value) {
          final field = key.toString();
          if (value is List) {
            return MapEntry(
              field,
              value.map((item) => item.toString()).toList(),
            );
          }
          return MapEntry(field, [value.toString()]);
        });
      }
    }
    return const {};
  }
}
