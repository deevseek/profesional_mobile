import 'transaction_item_model.dart';

abstract class TransactionItemRepository {
  Future<TransactionItemPage> getTransactionItems({
    String? search,
    String? transactionId,
    int page = 1,
  });

  Future<TransactionItem> getTransactionItem(String id);

  Future<TransactionItem> createTransactionItem(TransactionItem transactionItem);

  Future<TransactionItem> updateTransactionItem(String id, TransactionItem transactionItem);

  Future<void> deleteTransactionItem(String id);
}
