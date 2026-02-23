import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/pos_cart_item.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(dioProvider));
});

class TransactionResult {
  const TransactionResult({
    required this.invoice,
    required this.subtotal,
    required this.total,
    required this.change,
  });

  final String invoice;
  final int subtotal;
  final int total;
  final int change;
}

class TransactionRepository {
  const TransactionRepository(this._dio);

  final Dio _dio;

  Future<TransactionResult> createTransaction({
    required List<PosCartItem> items,
    required int taxPercent,
    required int paidAmount,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/transactions',
      data: {
        'items': items
            .map(
              (item) => {
                'product_id': item.product.id,
                'name': item.product.name,
                'price': item.product.price,
                'quantity': item.quantity,
                'discount': item.discount,
                'line_total': item.lineTotal,
              },
            )
            .toList(growable: false),
        'tax_percent': taxPercent,
        'paid_amount': paidAmount,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>? ?? response.data;
    if (data == null) {
      throw const FormatException('Response transaksi kosong');
    }

    return TransactionResult(
      invoice: _asString(data['invoice']),
      subtotal: _asInt(data['subtotal']),
      total: _asInt(data['total']),
      change: _asInt(data['change']),
    );
  }

  String _asString(dynamic value) => value?.toString() ?? '';

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
