import 'package:flutter/foundation.dart';

import '../data/payroll_repository_impl.dart';
import '../domain/payroll_model.dart';
import '../domain/payroll_repository.dart';

class PayrollController extends ChangeNotifier {
  PayrollController({PayrollRepository? repository})
      : _repository = repository ?? PayrollRepositoryImpl();

  final PayrollRepository _repository;

  bool _loading = false;
  String? _errorMessage;
  List<Payroll> _payrolls = const [];
  PayrollPaginationMeta? _meta;
  PayrollPaginationLinks? _links;
  String _employeeQuery = '';
  String _statusQuery = '';
  int _page = 1;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  List<Payroll> get payrolls => _payrolls;
  PayrollPaginationMeta? get meta => _meta;
  PayrollPaginationLinks? get links => _links;
  String get employeeQuery => _employeeQuery;
  String get statusQuery => _statusQuery;
  int get page => _page;

  Future<void> loadPayrolls({
    String? employee,
    String? status,
    int page = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    if (employee != null) {
      _employeeQuery = employee;
    }
    if (status != null) {
      _statusQuery = status;
    }
    _page = page;
    try {
      final result = await _repository.getPayrolls(
        employee: _employeeQuery.trim().isEmpty ? null : _employeeQuery,
        status: _statusQuery.trim().isEmpty ? null : _statusQuery,
        page: _page,
      );
      _payrolls = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load payrolls. Please try again.';
      _payrolls = const [];
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
