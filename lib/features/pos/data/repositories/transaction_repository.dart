import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/pos_cart_item.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';
import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(dioProvider));
});

class TransactionResult {
  const TransactionResult({
    required this.invoice,
    required this.subtotal,
    required this.total,
    required this.change,
    required this.raw,
  });

  final String invoice;
  final int subtotal;
  final int total;
  final int change;
  final Map<String, dynamic> raw;
}

class TransactionRepository {
  const TransactionRepository(this._dio);

  final Dio _dio;

  Future<TransactionResult> createTransaction({
    required List<PosCartItem> items,
    required int paidAmount,
    String paymentMethod = 'cash',
    int? customerId,
    int discount = 0,
  }) async {
    final subtotal = items.fold<int>(0, (sum, item) => sum + item.lineBaseTotal);
    final totalDiscount = discount + items.fold<int>(0, (sum, item) => sum + item.discount);
    final payable = subtotal - totalDiscount;
    if (paidAmount < payable) {
      throw const FormatException('Nominal bayar kurang dari total transaksi.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/transactions',
      data: {
        if (customerId != null && customerId > 0) 'customer_id': customerId,
        'payment_method': _normalizePaymentMethod(paymentMethod),
        'paid_amount': paidAmount,
        'discount': discount,
        'items': items
            .map(
              (item) => {
                'product_id': parseInt(item.product.id),
                'quantity': item.quantity,
                'price': item.product.price,
                'hpp': 0,
              },
            )
            .toList(growable: false),
      },
    );

    final data = unwrapDataMap(response.data);
    return TransactionResult(
      invoice: parseString(data['invoice'] ?? data['invoice_number']),
      subtotal: parseInt(data['subtotal'] ?? subtotal),
      total: parseInt(data['total'] ?? data['total_amount'] ?? payable),
      change: parseInt(data['change'] ?? data['change_amount']),
      raw: data,
    );
  }

  String _normalizePaymentMethod(String value) {
    final text = value.trim().toLowerCase();
    if (text.contains('transfer')) return 'transfer';
    if (text.contains('wallet') || text.contains('qris') || text.contains('e-wallet')) return 'e-wallet';
    return 'cash';
  }
}
