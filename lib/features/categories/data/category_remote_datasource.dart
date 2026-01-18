import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/category_model.dart';

class CategoryRemoteDataSource {
  CategoryRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<CategoryPage> fetchCategories({
    String? search,
    int page = 1,
    int? perPage,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/categories',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        if (perPage != null) 'per_page': perPage,
      },
    );

    return CategoryPage.fromJson(_ensureMap(response.data, message: 'Invalid categories response'));
  }

  Future<Category> fetchCategory(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/categories/$id');
    final payload = _ensureMap(response.data, message: 'Invalid category response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Category.fromJson(data);
    }

    return Category.fromJson(payload);
  }

  Future<Category> createCategory(Category category) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/categories',
      data: category.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid category response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Category.fromJson(data);
    }

    return Category.fromJson(payload);
  }

  Future<Category> updateCategory(String id, Category category) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/categories/$id',
      data: category.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid category response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Category.fromJson(data);
    }

    return Category.fromJson(payload);
  }

  Future<void> deleteCategory(String id) async {
    await _client.delete<void>('/categories/$id');
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
