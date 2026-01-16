import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/supplier_repository_impl.dart';
import '../domain/supplier_model.dart';
import '../domain/supplier_repository.dart';

class SupplierController extends ChangeNotifier {
  SupplierController({SupplierRepository? repository})
      : _repository = repository ?? SupplierRepositoryImpl();

  final SupplierRepository _repository;

  bool _loading = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<Supplier> _suppliers = const [];
  SupplierPaginationMeta? _meta;
  SupplierPaginationLinks? _links;
  String _searchQuery = '';
  int _page = 1;
  Supplier? _supplier;
  Map<String, List<String>> _fieldErrors = const {};

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Supplier> get suppliers => _suppliers;
  SupplierPaginationMeta? get meta => _meta;
  SupplierPaginationLinks? get links => _links;
  String get searchQuery => _searchQuery;
  int get page => _page;
  Supplier? get supplier => _supplier;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  Future<void> loadSuppliers({String? search, int page = 1}) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    _searchQuery = search ?? _searchQuery;
    _page = page;
    try {
      final result = await _repository.getSuppliers(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _page,
      );
      _suppliers = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load suppliers. Please try again.';
      _suppliers = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSupplier(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    try {
      _supplier = await _repository.getSupplier(id);
    } catch (error) {
      _errorMessage = 'Unable to load supplier details.';
      _supplier = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createSupplier(Supplier supplier) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final created = await _repository.createSupplier(supplier);
      _supplier = created;
      _successMessage = 'Supplier created successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to create supplier.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateSupplier(String id, Supplier supplier) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final updated = await _repository.updateSupplier(id, supplier);
      _supplier = updated;
      _successMessage = 'Supplier updated successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to update supplier.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteSupplier(String id) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      await _repository.deleteSupplier(id);
      _successMessage = 'Supplier deleted.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to delete supplier.');
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
