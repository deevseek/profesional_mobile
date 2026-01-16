import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<ProductPage> fetchProducts({String? search, int page = 1}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/products',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
      },
    );

    return ProductPage.fromJson(_ensureMap(response.data, message: 'Invalid products response'));
  }

  Future<Product> fetchProduct(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/products/$id');
    final payload = _ensureMap(response.data, message: 'Invalid product response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Product.fromJson(data);
    }

    return Product.fromJson(payload);
  }

  Future<Product> createProduct(Product product) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/products',
      data: product.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid product response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Product.fromJson(data);
    }

    return Product.fromJson(payload);
  }

  Future<Product> updateProduct(String id, Product product) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/products/$id',
      data: product.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid product response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Product.fromJson(data);
    }

    return Product.fromJson(payload);
  }

  Future<void> deleteProduct(String id) async {
    await _client.delete<void>('/products/$id');
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
