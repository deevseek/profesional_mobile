import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/transaction_item_model.dart';

class TransactionItemRemoteDataSource {
  TransactionItemRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<TransactionItemPage> fetchTransactionItems({
    String? search,
    String? transactionId,
    int page = 1,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      'transaction-items',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (transactionId != null && transactionId.trim().isNotEmpty)
          'transaction_id': transactionId.trim(),
        'page': page,
      },
    );

    return TransactionItemPage.fromJson(
      _ensureMap(response.data, message: 'Invalid transaction items response'),
    );
  }

  Future<TransactionItem> fetchTransactionItem(String id) async {
    final response = await _client.get<Map<String, dynamic>>('transaction-items/$id');
    final payload = _ensureMap(response.data, message: 'Invalid transaction item response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return TransactionItem.fromJson(data);
    }

    return TransactionItem.fromJson(payload);
  }

  Future<TransactionItem> createTransactionItem(TransactionItem transactionItem) async {
    final response = await _client.post<Map<String, dynamic>>(
      'transaction-items',
      data: transactionItem.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid transaction item response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return TransactionItem.fromJson(data);
    }

    return TransactionItem.fromJson(payload);
  }

  Future<TransactionItem> updateTransactionItem(String id, TransactionItem transactionItem) async {
    final response = await _client.patch<Map<String, dynamic>>(
      'transaction-items/$id',
      data: transactionItem.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid transaction item response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return TransactionItem.fromJson(data);
    }

    return TransactionItem.fromJson(payload);
  }

  Future<void> deleteTransactionItem(String id) async {
    await _client.delete<void>('transaction-items/$id');
  }

  Map<String, dynamic> _ensureMap(
    dynamic data, {
    required String message,
  }) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.map((key, value) => MapEntry('$key', value));
    }

    throw ApiException(message);
  }
}
