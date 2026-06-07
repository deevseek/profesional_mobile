import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/receipt_payload_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(ref.watch(dioProvider));
});

class ReceiptRepository {
  const ReceiptRepository(this._dio);

  final Dio _dio;

  Future<ReceiptPayloadModel> getTransactionReceipt(int transactionId) async {
    final response = await _dio.get<Map<String, dynamic>>('/transactions/$transactionId/receipt');
    final body = response.data;
    if (body == null) {
      throw const FormatException('Response struk transaksi tidak valid.');
    }
    return ReceiptPayloadModel.fromJson(body);
  }
}
