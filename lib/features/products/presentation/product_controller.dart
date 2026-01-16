import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/product_repository_impl.dart';
import '../domain/product_model.dart';
import '../domain/product_repository.dart';

class ProductController extends ChangeNotifier {
  ProductController({ProductRepository? repository})
      : _repository = repository ?? ProductRepositoryImpl();

  final ProductRepository _repository;

  bool _loading = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<Product> _products = const [];
  ProductPaginationMeta? _meta;
  ProductPaginationLinks? _links;
  String _searchQuery = '';
  int _page = 1;
  Product? _product;
  Map<String, List<String>> _fieldErrors = const {};

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Product> get products => _products;
  ProductPaginationMeta? get meta => _meta;
  ProductPaginationLinks? get links => _links;
  String get searchQuery => _searchQuery;
  int get page => _page;
  Product? get product => _product;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  Future<void> loadProducts({String? search, int page = 1}) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    _searchQuery = search ?? _searchQuery;
    _page = page;
    try {
      final result = await _repository.getProducts(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _page,
      );
      _products = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load products. Please try again.';
      _products = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProduct(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    try {
      _product = await _repository.getProduct(id);
    } catch (error) {
      _errorMessage = 'Unable to load product details.';
      _product = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createProduct(Product product) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final created = await _repository.createProduct(product);
      _product = created;
      _successMessage = 'Product created successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to create product.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateProduct(String id, Product product) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final updated = await _repository.updateProduct(id, product);
      _product = updated;
      _successMessage = 'Product updated successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to update product.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteProduct(String id) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      await _repository.deleteProduct(id);
      _successMessage = 'Product deleted.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to delete product.');
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
