import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';
import 'package:profesionalservis_mobile/features/transaction/data/repositories/transactions_repository.dart';

final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier(ref.read(transactionsRepositoryProvider))..loadTransactions();
});

final transactionDetailProvider = FutureProvider.family<TransactionModel, String>((ref, id) {
  final repository = ref.watch(transactionsRepositoryProvider);
  return repository.getTransactionDetail(id);
});

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier(this._repository) : super(const TransactionState());

  final TransactionsRepository _repository;

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final transactions = await _repository.getTransactions(
        startDate: state.startDate,
        endDate: state.endDate,
        search: state.searchInvoice,
      );
      state = state.copyWith(isLoading: false, transactions: transactions);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat transaksi. Coba lagi.',
      );
    }
  }

  Future<void> setSearchInvoice(String value) async {
    state = state.copyWith(searchInvoice: value);
    await loadTransactions();
  }

  Future<void> setDateFilter({DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(startDate: startDate, endDate: endDate);
    await loadTransactions();
  }

  Future<void> resetFilter() async {
    state = state.copyWith(startDate: null, endDate: null, searchInvoice: '');
    await loadTransactions();
  }
}

class TransactionState {
  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchInvoice = '',
    this.startDate,
    this.endDate,
  });

  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? errorMessage;
  final String searchInvoice;
  final DateTime? startDate;
  final DateTime? endDate;

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? errorMessage,
    String? searchInvoice,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchInvoice: searchInvoice ?? this.searchInvoice,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
