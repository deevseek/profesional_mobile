import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/purchase_item_model.dart';

class PurchaseItemRemoteDataSource {
  PurchaseItemRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<PurchaseItemPage> fetchPurchaseItems({
    String? search,
    String? purchaseId,
    String? productId,
    int? perPage,
    int page = 1,
  }) async {
    final resolvedSearch = (search != null && search.trim().isNotEmpty)
        ? search.trim()
        : null;
    final resolvedPurchaseId =
        (purchaseId != null && purchaseId.trim().isNotEmpty) ? purchaseId.trim() : null;
    final resolvedProductId =
        (productId != null && productId.trim().isNotEmpty) ? productId.trim() : null;
    final response = await _client.get<Map<String, dynamic>>(
      'purchase-items',
      queryParameters: {
        if (resolvedSearch != null) 'search': resolvedSearch,
        if (resolvedPurchaseId != null) 'purchase_id': resolvedPurchaseId,
        if (resolvedProductId != null) 'product_id': resolvedProductId,
        if (perPage != null) 'per_page': perPage,
        'page': page,
      },
    );

    return PurchaseItemPage.fromJson(
      _ensureMap(response.data, message: 'Invalid purchase items response'),
    );
  }

  Future<PurchaseItem> fetchPurchaseItem(String id) async {
    final response = await _client.get<Map<String, dynamic>>('purchase-items/$id');
    final payload = _ensureMap(response.data, message: 'Invalid purchase item response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return PurchaseItem.fromJson(data);
    }

    return PurchaseItem.fromJson(payload);
  }

  Future<PurchaseItem> createPurchaseItem(PurchaseItem purchaseItem) async {
    final response = await _client.post<Map<String, dynamic>>(
      'purchase-items',
      data: purchaseItem.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid purchase item response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return PurchaseItem.fromJson(data);
    }

    return PurchaseItem.fromJson(payload);
  }

  Future<PurchaseItem> updatePurchaseItem(String id, PurchaseItem purchaseItem) async {
    final response = await _client.patch<Map<String, dynamic>>(
      'purchase-items/$id',
      data: purchaseItem.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid purchase item response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return PurchaseItem.fromJson(data);
    }

    return PurchaseItem.fromJson(payload);
  }

  Future<void> deletePurchaseItem(String id) async {
    await _client.delete<void>('purchase-items/$id');
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
