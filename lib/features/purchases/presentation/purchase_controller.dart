import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/purchase_repository_impl.dart';
import '../domain/purchase_model.dart';
import '../domain/purchase_repository.dart';

class PurchaseController extends ChangeNotifier {
  PurchaseController({PurchaseRepository? repository})
      : _repository = repository ?? PurchaseRepositoryImpl();

  final PurchaseRepository _repository;

  bool _loading = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<Purchase> _purchases = const [];
  PurchasePaginationMeta? _meta;
  PurchasePaginationLinks? _links;
  String _searchQuery = '';
  int _page = 1;
  Purchase? _purchase;
  Map<String, List<String>> _fieldErrors = const {};

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Purchase> get purchases => _purchases;
  PurchasePaginationMeta? get meta => _meta;
  PurchasePaginationLinks? get links => _links;
  String get searchQuery => _searchQuery;
  int get page => _page;
  Purchase? get purchase => _purchase;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  Future<void> loadPurchases({
    String? search,
    int page = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    if (search != null) {
      _searchQuery = search;
    }
    _page = page;
    try {
      final result = await _repository.getPurchases(
        search: _searchQuery.trim().isEmpty ? null : _searchQuery,
        page: _page,
      );
      _purchases = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load purchases. Please try again.';
      _purchases = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPurchase(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    try {
      _purchase = await _repository.getPurchase(id);
    } catch (error) {
      _errorMessage = 'Unable to load purchase details.';
      _purchase = null;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    notifyListeners();
  }

  Future<bool> createPurchase(Purchase purchase) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final created = await _repository.createPurchase(purchase);
      _purchase = created;
      _successMessage = 'Purchase created successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to create purchase.');
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
