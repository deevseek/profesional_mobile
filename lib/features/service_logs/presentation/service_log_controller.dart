import 'package:flutter/foundation.dart';

import '../data/service_log_repository_impl.dart';
import '../domain/service_log_model.dart';
import '../domain/service_log_repository.dart';

class ServiceLogController extends ChangeNotifier {
  ServiceLogController({ServiceLogRepository? repository})
      : _repository = repository ?? ServiceLogRepositoryImpl();

  final ServiceLogRepository _repository;

  bool _loading = false;
  String? _errorMessage;
  List<ServiceLog> _serviceLogs = const [];
  ServiceLogPaginationMeta? _meta;
  ServiceLogPaginationLinks? _links;
  String _searchQuery = '';
  String _serviceIdQuery = '';
  String _statusQuery = '';
  int _page = 1;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  List<ServiceLog> get serviceLogs => _serviceLogs;
  ServiceLogPaginationMeta? get meta => _meta;
  ServiceLogPaginationLinks? get links => _links;
  String get searchQuery => _searchQuery;
  String get serviceIdQuery => _serviceIdQuery;
  String get statusQuery => _statusQuery;
  int get page => _page;

  Future<void> loadServiceLogs({
    String? search,
    String? serviceId,
    String? status,
    int page = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _searchQuery = search ?? _searchQuery;
    _serviceIdQuery = serviceId ?? _serviceIdQuery;
    _statusQuery = status ?? _statusQuery;
    _page = page;
    try {
      final result = await _repository.getServiceLogs(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        serviceId: _serviceIdQuery.isEmpty ? null : _serviceIdQuery,
        status: _statusQuery.isEmpty ? null : _statusQuery,
        page: _page,
      );
      _serviceLogs = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load service logs. Please try again.';
      _serviceLogs = const [];
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
