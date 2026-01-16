import '../domain/transaction_item_model.dart';
import '../domain/transaction_item_repository.dart';
import 'transaction_item_remote_datasource.dart';

class TransactionItemRepositoryImpl implements TransactionItemRepository {
  TransactionItemRepositoryImpl({TransactionItemRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TransactionItemRemoteDataSource();

  final TransactionItemRemoteDataSource _remoteDataSource;

  @override
  Future<TransactionItemPage> getTransactionItems({
    String? search,
    String? transactionId,
    int page = 1,
  }) {
    return _remoteDataSource.fetchTransactionItems(
      search: search,
      transactionId: transactionId,
      page: page,
    );
  }

  @override
  Future<TransactionItem> getTransactionItem(String id) {
    return _remoteDataSource.fetchTransactionItem(id);
  }

  @override
  Future<TransactionItem> createTransactionItem(TransactionItem transactionItem) {
    return _remoteDataSource.createTransactionItem(transactionItem);
  }

  @override
  Future<TransactionItem> updateTransactionItem(String id, TransactionItem transactionItem) {
    return _remoteDataSource.updateTransactionItem(id, transactionItem);
  }

  @override
  Future<void> deleteTransactionItem(String id) {
    return _remoteDataSource.deleteTransactionItem(id);
  }
}
