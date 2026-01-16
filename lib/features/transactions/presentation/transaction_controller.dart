import 'package:flutter/foundation.dart';

import '../data/transaction_repository_impl.dart';
import '../domain/transaction_model.dart';
import '../domain/transaction_repository.dart';

class TransactionController extends ChangeNotifier {
  TransactionController({TransactionRepository? repository})
      : _repository = repository ?? TransactionRepositoryImpl();

  final TransactionRepository _repository;

  bool _loading = false;
  String? _errorMessage;
  List<Transaction> _transactions = const [];
  TransactionPaginationMeta? _meta;
  TransactionPaginationLinks? _links;
  String _invoiceQuery = '';
  String _statusQuery = '';
  int _page = 1;
  Transaction? _transaction;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  List<Transaction> get transactions => _transactions;
  TransactionPaginationMeta? get meta => _meta;
  TransactionPaginationLinks? get links => _links;
  String get invoiceQuery => _invoiceQuery;
  String get statusQuery => _statusQuery;
  int get page => _page;
  Transaction? get transaction => _transaction;

  Future<void> loadTransactions({
    String? invoiceNumber,
    String? status,
    int page = 1,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    if (invoiceNumber != null) {
      _invoiceQuery = invoiceNumber;
    }
    if (status != null) {
      _statusQuery = status;
    }
    _page = page;
    try {
      final result = await _repository.getTransactions(
        invoiceNumber: _invoiceQuery.trim().isEmpty ? null : _invoiceQuery,
        status: _statusQuery.trim().isEmpty ? null : _statusQuery,
        page: _page,
      );
      _transactions = result.data;
      _meta = result.meta;
      _links = result.links;
    } catch (error) {
      _errorMessage = 'Unable to load transactions. Please try again.';
      _transactions = const [];
      _meta = null;
      _links = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTransaction(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _transaction = await _repository.getTransaction(id);
    } catch (error) {
      _errorMessage = 'Unable to load transaction details.';
      _transaction = null;
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
