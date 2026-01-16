import 'transaction_model.dart';

abstract class TransactionRepository {
  Future<TransactionPage> getTransactions({
    String? invoiceNumber,
    String? status,
    int page = 1,
  });

  Future<Transaction> getTransaction(String id);
}
