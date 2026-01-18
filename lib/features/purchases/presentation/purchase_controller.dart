import 'package:flutter/foundation.dart';

import '../data/purchase_repository_impl.dart';
import '../domain/purchase_model.dart';
import '../domain/purchase_repository.dart';

class PurchaseController extends ChangeNotifier {
  PurchaseController({PurchaseRepository? repository})
      : _repository = repository ?? PurchaseRepositoryImpl();

  final PurchaseRepository _repository;

  bool _loading = false;
  String? _errorMessage;
  List<Purchase> _purchases = const [];
  PurchasePaginationMeta? _meta;
  PurchasePaginationLinks? _links;
  String _searchQuery = '';
  int _page = 1;
  Purchase? _purchase;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  List<Purchase> get purchases => _purchases;
  PurchasePaginationMeta? get meta => _meta;
  PurchasePaginationLinks? get links => _links;
  String get searchQuery => _searchQuery;
  int get page => _page;
  Purchase? get purchase => _purchase;

  Future<void> loadPurchases({
    String? search,
    int page = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;
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
