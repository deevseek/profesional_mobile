import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/product/data/models/product_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';
import 'package:profesionalservis_mobile/shared/models/paginated_response.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

class ProductRepository {
  const ProductRepository(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<ProductModel>> getProducts({
    required int page,
    String? search,
    String? category,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (category != null && category.isNotEmpty) 'category_id': category,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Response produk kosong.');
    }

    return PaginatedResponse<ProductModel>.fromJson(
      data,
      ProductModel.fromJson,
    );
  }

  Future<void> addProduct(ProductModel product) async {
    await _dio.post<void>('/products', data: _toPayload(product));
  }

  Future<void> editProduct({required String id, required ProductModel product}) async {
    await _dio.patch<void>('/products/$id', data: _toPayload(product));
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete<void>('/products/$id');
  }

  Map<String, dynamic> _toPayload(ProductModel product) {
    return {
      'name': product.name,
      'sku': product.sku,
      if (product.category.trim().isNotEmpty) 'category_id': product.category,
      'stock': product.stock,
      'price': product.price,
      'cost_price': 0,
      'avg_cost': 0,
      'pricing_mode': 'manual',
      'margin_percentage': 0,
      'description': product.description,
    };
  }
}
