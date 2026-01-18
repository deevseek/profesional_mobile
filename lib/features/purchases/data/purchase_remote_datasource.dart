import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/purchase_model.dart';

class PurchaseRemoteDataSource {
  PurchaseRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<PurchasePage> fetchPurchases({
    String? search,
    int page = 1,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      'purchases',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
      },
    );

    return PurchasePage.fromJson(
      _ensureMap(response.data, message: 'Invalid purchases response'),
    );
  }

  Future<Purchase> fetchPurchase(String id) async {
    final response = await _client.get<Map<String, dynamic>>('purchases/$id');
    final payload = _ensureMap(response.data, message: 'Invalid purchase response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Purchase.fromJson(data);
    }

    return Purchase.fromJson(payload);
  }

  Future<Purchase> createPurchase(Purchase purchase) async {
    final response = await _client.post<Map<String, dynamic>>(
      'purchases',
      data: purchase.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid purchase response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Purchase.fromJson(data);
    }

    return Purchase.fromJson(payload);
  }

  Future<Purchase> updatePurchase(String id, Map<String, dynamic> payload) async {
    final response = await _client.patch<Map<String, dynamic>>(
      'purchases/$id',
      data: payload,
    );
    final responsePayload =
        _ensureMap(response.data, message: 'Invalid purchase response');
    final data = responsePayload['data'];
    if (data is Map<String, dynamic>) {
      return Purchase.fromJson(data);
    }

    return Purchase.fromJson(responsePayload);
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
