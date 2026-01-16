import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/customer_repository_impl.dart';
import '../domain/customer_model.dart';
import '../domain/customer_repository.dart';

class CustomerController extends ChangeNotifier {
  CustomerController({CustomerRepository? repository})
      : _repository = repository ?? CustomerRepositoryImpl();

  final CustomerRepository _repository;

  bool _loading = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<Customer> _customers = const [];
  CustomerPaginationMeta? _meta;
  CustomerPaginationLinks? _links;
  String _searchQuery = '';
  int _page = 1;
  int _perPage = 15;
  Customer? _customer;
  Map<String, List<String>> _fieldErrors = const {};

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Customer> get customers => _customers;
  CustomerPaginationMeta? get meta => _meta;
  CustomerPaginationLinks? get links => _links;
  String get searchQuery => _searchQuery;
  int get page => _page;
  int get perPage => _perPage;
  Customer? get customer => _customer;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  Future<void> loadCustomers({String? search, int page = 1, int? perPage}) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    _searchQuery = search ?? _searchQuery;
    _page = page;
    if (perPage != null) {
      _perPage = perPage;
    }
    try {
      final result = await _repository.getCustomers(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _page,
        perPage: _perPage,
      );
      _customers = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load customers. Please try again.';
      _customers = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCustomer(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    try {
      _customer = await _repository.getCustomer(id);
    } catch (error) {
      _errorMessage = 'Unable to load customer details.';
      _customer = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCustomer(Customer customer) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final created = await _repository.createCustomer(customer);
      _customer = created;
      _successMessage = 'Customer created successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to create customer.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateCustomer(String id, Customer customer) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final updated = await _repository.updateCustomer(id, customer);
      _customer = updated;
      _successMessage = 'Customer updated successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to update customer.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteCustomer(String id) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      await _repository.deleteCustomer(id);
      _successMessage = 'Customer deleted.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to delete customer.');
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
