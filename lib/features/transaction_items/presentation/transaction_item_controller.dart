import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/transaction_item_repository_impl.dart';
import '../domain/transaction_item_model.dart';
import '../domain/transaction_item_repository.dart';

class TransactionItemController extends ChangeNotifier {
  TransactionItemController({TransactionItemRepository? repository})
      : _repository = repository ?? TransactionItemRepositoryImpl();

  final TransactionItemRepository _repository;

  bool _loading = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<TransactionItem> _transactionItems = const [];
  TransactionItemPaginationMeta? _meta;
  TransactionItemPaginationLinks? _links;
  String _searchQuery = '';
  String _transactionIdQuery = '';
  int _page = 1;
  TransactionItem? _transactionItem;
  Map<String, List<String>> _fieldErrors = const {};

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<TransactionItem> get transactionItems => _transactionItems;
  TransactionItemPaginationMeta? get meta => _meta;
  TransactionItemPaginationLinks? get links => _links;
  String get searchQuery => _searchQuery;
  String get transactionIdQuery => _transactionIdQuery;
  int get page => _page;
  TransactionItem? get transactionItem => _transactionItem;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  Future<void> loadTransactionItems({
    String? search,
    String? transactionId,
    int page = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    _searchQuery = search ?? _searchQuery;
    _transactionIdQuery = transactionId ?? _transactionIdQuery;
    _page = page;
    try {
      final result = await _repository.getTransactionItems(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        transactionId: _transactionIdQuery.isEmpty ? null : _transactionIdQuery,
        page: _page,
      );
      _transactionItems = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load transaction items. Please try again.';
      _transactionItems = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTransactionItem(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    try {
      _transactionItem = await _repository.getTransactionItem(id);
    } catch (error) {
      _errorMessage = 'Unable to load transaction item details.';
      _transactionItem = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTransactionItem(TransactionItem transactionItem) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final created = await _repository.createTransactionItem(transactionItem);
      _transactionItem = created;
      _successMessage = 'Transaction item created successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to create transaction item.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateTransactionItem(String id, TransactionItem transactionItem) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final updated = await _repository.updateTransactionItem(id, transactionItem);
      _transactionItem = updated;
      _successMessage = 'Transaction item updated successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to update transaction item.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteTransactionItem(String id) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      await _repository.deleteTransactionItem(id);
      _successMessage = 'Transaction item deleted.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to delete transaction item.');
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
