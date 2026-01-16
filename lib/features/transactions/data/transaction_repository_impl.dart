import '../domain/transaction_model.dart';
import '../domain/transaction_repository.dart';
import 'transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({TransactionRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TransactionRemoteDataSource();

  final TransactionRemoteDataSource _remoteDataSource;

  @override
  Future<TransactionPage> getTransactions({
    String? invoiceNumber,
    String? status,
    int page = 1,
  }) {
    return _remoteDataSource.fetchTransactions(
      invoiceNumber: invoiceNumber,
      status: status,
      page: page,
    );
  }

  @override
  Future<Transaction> getTransaction(String id) {
    return _remoteDataSource.fetchTransaction(id);
  }
}
