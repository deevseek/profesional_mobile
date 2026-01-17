import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/transaction_model.dart';

class TransactionRemoteDataSource {
  TransactionRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<TransactionPage> fetchTransactions({
    String? invoiceNumber,
    String? status,
    int page = 1,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      'transactions',
      queryParameters: {
        if (invoiceNumber != null && invoiceNumber.trim().isNotEmpty)
          'invoice_number': invoiceNumber.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        'page': page,
      },
    );

    return TransactionPage.fromJson(
      _ensureMap(response.data, message: 'Invalid transactions response'),
    );
  }

  Future<Transaction> fetchTransaction(String id) async {
    final response = await _client.get<Map<String, dynamic>>('transactions/$id');
    final payload = _ensureMap(response.data, message: 'Invalid transaction response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Transaction.fromJson(data);
    }

    return Transaction.fromJson(payload);
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
