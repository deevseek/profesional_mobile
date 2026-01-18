import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/purchase_item_repository_impl.dart';
import '../domain/purchase_item_model.dart';
import '../domain/purchase_item_repository.dart';

class PurchaseItemController extends ChangeNotifier {
  PurchaseItemController({PurchaseItemRepository? repository})
      : _repository = repository ?? PurchaseItemRepositoryImpl();

  final PurchaseItemRepository _repository;

  bool _loading = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<PurchaseItem> _purchaseItems = const [];
  PurchaseItemPaginationMeta? _meta;
  PurchaseItemPaginationLinks? _links;
  String _searchQuery = '';
  String _purchaseIdQuery = '';
  String _productIdQuery = '';
  int? _perPage;
  int _page = 1;
  PurchaseItem? _purchaseItem;
  Map<String, List<String>> _fieldErrors = const {};

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<PurchaseItem> get purchaseItems => _purchaseItems;
  PurchaseItemPaginationMeta? get meta => _meta;
  PurchaseItemPaginationLinks? get links => _links;
  String get searchQuery => _searchQuery;
  String get purchaseIdQuery => _purchaseIdQuery;
  String get productIdQuery => _productIdQuery;
  int? get perPage => _perPage;
  int get page => _page;
  PurchaseItem? get purchaseItem => _purchaseItem;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  Future<void> loadPurchaseItems({
    String? search,
    String? purchaseId,
    String? productId,
    int? perPage,
    int page = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    _searchQuery = search ?? _searchQuery;
    _purchaseIdQuery = purchaseId ?? _purchaseIdQuery;
    _productIdQuery = productId ?? _productIdQuery;
    _perPage = perPage ?? _perPage;
    _page = page;
    try {
      final result = await _repository.getPurchaseItems(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        purchaseId: _purchaseIdQuery.isEmpty ? null : _purchaseIdQuery,
        productId: _productIdQuery.isEmpty ? null : _productIdQuery,
        perPage: _perPage,
        page: _page,
      );
      _purchaseItems = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load purchase items. Please try again.';
      _purchaseItems = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPurchaseItem(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    try {
      _purchaseItem = await _repository.getPurchaseItem(id);
    } catch (error) {
      _errorMessage = 'Unable to load purchase item details.';
      _purchaseItem = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createPurchaseItem(PurchaseItem purchaseItem) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final created = await _repository.createPurchaseItem(purchaseItem);
      _purchaseItem = created;
      _successMessage = 'Purchase item created successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to create purchase item.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updatePurchaseItem(String id, PurchaseItem purchaseItem) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final updated = await _repository.updatePurchaseItem(id, purchaseItem);
      _purchaseItem = updated;
      _successMessage = 'Purchase item updated successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to update purchase item.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deletePurchaseItem(String id) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      await _repository.deletePurchaseItem(id);
      _successMessage = 'Purchase item deleted.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to delete purchase item.');
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
