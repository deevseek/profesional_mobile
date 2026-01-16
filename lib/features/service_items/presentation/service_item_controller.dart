import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/service_item_repository_impl.dart';
import '../domain/service_item_model.dart';
import '../domain/service_item_repository.dart';

class ServiceItemController extends ChangeNotifier {
  ServiceItemController({ServiceItemRepository? repository})
      : _repository = repository ?? ServiceItemRepositoryImpl();

  final ServiceItemRepository _repository;

  bool _loading = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<ServiceItem> _serviceItems = const [];
  ServiceItemPaginationMeta? _meta;
  ServiceItemPaginationLinks? _links;
  String _searchQuery = '';
  String _serviceIdQuery = '';
  int _page = 1;
  ServiceItem? _serviceItem;
  Map<String, List<String>> _fieldErrors = const {};

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<ServiceItem> get serviceItems => _serviceItems;
  ServiceItemPaginationMeta? get meta => _meta;
  ServiceItemPaginationLinks? get links => _links;
  String get searchQuery => _searchQuery;
  String get serviceIdQuery => _serviceIdQuery;
  int get page => _page;
  ServiceItem? get serviceItem => _serviceItem;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  Future<void> loadServiceItems({String? search, String? serviceId, int page = 1}) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    _searchQuery = search ?? _searchQuery;
    _serviceIdQuery = serviceId ?? _serviceIdQuery;
    _page = page;
    try {
      final result = await _repository.getServiceItems(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        serviceId: _serviceIdQuery.isEmpty ? null : _serviceIdQuery,
        page: _page,
      );
      _serviceItems = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load service items. Please try again.';
      _serviceItems = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadServiceItem(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    try {
      _serviceItem = await _repository.getServiceItem(id);
    } catch (error) {
      _errorMessage = 'Unable to load service item details.';
      _serviceItem = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createServiceItem(ServiceItem serviceItem) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final created = await _repository.createServiceItem(serviceItem);
      _serviceItem = created;
      _successMessage = 'Service item created successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to create service item.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateServiceItem(String id, ServiceItem serviceItem) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final updated = await _repository.updateServiceItem(id, serviceItem);
      _serviceItem = updated;
      _successMessage = 'Service item updated successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to update service item.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteServiceItem(String id) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      await _repository.deleteServiceItem(id);
      _successMessage = 'Service item deleted.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to delete service item.');
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
