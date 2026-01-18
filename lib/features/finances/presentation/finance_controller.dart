import 'package:flutter/foundation.dart';

import '../data/finance_repository_impl.dart';
import '../domain/finance_model.dart';
import '../domain/finance_repository.dart';

class FinanceController extends ChangeNotifier {
  FinanceController({FinanceRepository? repository})
      : _repository = repository ?? FinanceRepositoryImpl();

  final FinanceRepository _repository;

  bool _loading = false;
  String? _errorMessage;
  List<Finance> _finances = const [];
  FinancePaginationMeta? _meta;
  FinancePaginationLinks? _links;
  String _typeQuery = '';
  String _descriptionQuery = '';
  int _page = 1;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  List<Finance> get finances => _finances;
  FinancePaginationMeta? get meta => _meta;
  FinancePaginationLinks? get links => _links;
  String get typeQuery => _typeQuery;
  String get descriptionQuery => _descriptionQuery;
  int get page => _page;

  Future<void> loadFinances({
    String? type,
    String? description,
    int page = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    if (type != null) {
      _typeQuery = type;
    }
    if (description != null) {
      _descriptionQuery = description;
    }
    _page = page;
    try {
      final result = await _repository.getFinances(
        type: _typeQuery.trim().isEmpty ? null : _typeQuery,
        description: _descriptionQuery.trim().isEmpty ? null : _descriptionQuery,
        page: _page,
      );
      _finances = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load finances. Please try again.';
      _finances = const [];
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
