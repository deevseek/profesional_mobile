import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(ref.watch(dioProvider));
});

class TransactionsRepository {
  const TransactionsRepository(this._dio);

  final Dio _dio;

  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String search = '',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/transactions',
      queryParameters: {
        if (startDate != null) 'start_date': _yyyyMmDd(startDate),
        if (endDate != null) 'end_date': _yyyyMmDd(endDate),
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final body = response.data;
    final data = body?['data'];

    final listRaw = data is Map<String, dynamic>
        ? data['items'] ?? data['data'] ?? data['transactions']
        : data ?? body?['items'];

    if (listRaw is! List) {
      return const [];
    }

    return listRaw
        .whereType<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .toList(growable: false);
  }

  Future<TransactionModel> getTransactionDetail(String transactionId) async {
    final response = await _dio.get<Map<String, dynamic>>('/transactions/$transactionId');

    final body = response.data;
    final data = body?['data'];
    final raw = data is Map<String, dynamic> ? data : body;

    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Detail transaksi tidak valid');
    }

    return TransactionModel.fromJson(raw);
  }

  String _yyyyMmDd(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
