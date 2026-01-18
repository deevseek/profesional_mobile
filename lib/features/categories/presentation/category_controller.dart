import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/errors/api_exception.dart';
import '../data/category_repository_impl.dart';
import '../domain/category_model.dart';
import '../domain/category_repository.dart';

class CategoryController extends ChangeNotifier {
  CategoryController({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepositoryImpl();

  final CategoryRepository _repository;

  bool _loading = false;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<Category> _categories = const [];
  CategoryPaginationMeta? _meta;
  CategoryPaginationLinks? _links;
  String _searchQuery = '';
  int _page = 1;
  int _perPage = 15;
  Category? _category;
  Map<String, List<String>> _fieldErrors = const {};

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Category> get categories => _categories;
  CategoryPaginationMeta? get meta => _meta;
  CategoryPaginationLinks? get links => _links;
  String get searchQuery => _searchQuery;
  int get page => _page;
  int get perPage => _perPage;
  Category? get category => _category;
  Map<String, List<String>> get fieldErrors => _fieldErrors;

  Future<void> loadCategories({String? search, int page = 1, int? perPage}) async {
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
      final result = await _repository.getCategories(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: _page,
        perPage: _perPage,
      );
      _categories = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load categories. Please try again.';
      _categories = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCategory(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    try {
      _category = await _repository.getCategory(id);
    } catch (error) {
      _errorMessage = 'Unable to load category details.';
      _category = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCategory(Category category) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final created = await _repository.createCategory(category);
      _category = created;
      _successMessage = 'Category created successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to create category.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateCategory(String id, Category category) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      final updated = await _repository.updateCategory(id, category);
      _category = updated;
      _successMessage = 'Category updated successfully.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to update category.');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteCategory(String id) async {
    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    try {
      await _repository.deleteCategory(id);
      _successMessage = 'Category deleted.';
      return true;
    } catch (error) {
      _handleError(error, fallbackMessage: 'Unable to delete category.');
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
