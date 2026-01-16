import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/service_repository_impl.dart';
import '../domain/service_model.dart';
import '../domain/service_repository.dart';

class ServiceController extends ChangeNotifier {
  ServiceController({ServiceRepository? repository})
      : _repository = repository ?? ServiceRepositoryImpl();

  final ServiceRepository _repository;

  bool _loading = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<Service> _services = const [];
  ServicePaginationMeta? _meta;
  ServicePaginationLinks? _links;
  String _customerNameQuery = '';
  String _statusQuery = '';
  int _page = 1;
  Service? _service;
  Map<String, List<String>> _fieldErrors = const {};

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Service> get services => _services;
  ServicePaginationMeta? get meta => _meta;
  ServicePaginationLinks? get links => _links;
  String get customerNameQuery => _customerNameQuery;
  String get statusQuery => _statusQuery;
  int get page => _page;
  Service? get service => _service;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  Future<void> loadServices({String? customerName, String? status, int page = 1}) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    if (customerName != null) {
      _customerNameQuery = customerName;
    }
    if (status != null) {
      _statusQuery = status;
    }
    _page = page;
    try {
      final result = await _repository.getServices(
        customerName: _customerNameQuery.trim().isEmpty ? null : _customerNameQuery,
        status: _statusQuery.trim().isEmpty ? null : _statusQuery,
        page: _page,
      );
      _services = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load services. Please try again.';
      _services = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadService(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    try {
      _service = await _repository.getService(id);
    } catch (error) {
      _errorMessage = 'Unable to load service details.';
      _service = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createService(Service service) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final created = await _repository.createService(service);
      _service = created;
      _successMessage = 'Service created successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to create service.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateService(String id, Service service) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final updated = await _repository.updateService(id, service);
      _service = updated;
      _successMessage = 'Service updated successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to update service.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteService(String id) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      await _repository.deleteService(id);
      _successMessage = 'Service deleted.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to delete service.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    notifyListeners();
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
