import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/category/data/models/category_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';
import 'package:profesionalservis_mobile/shared/models/paginated_response.dart';
import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => CategoryRepository(ref.watch(dioProvider)));
class CategoryRepository {
  const CategoryRepository(this._dio);
  final Dio _dio;
  Future<PaginatedResponse<CategoryModel>> getCategories({int page = 1, String? search}) async => PaginatedResponse.fromJson((await _dio.get<Map<String, dynamic>>('/categories', queryParameters: {'page': page, if (search != null && search.isNotEmpty) 'search': search})).data ?? {}, CategoryModel.fromJson);
  Future<CategoryModel> getCategory(String id) async => CategoryModel.fromJson(unwrapDataMap((await _dio.get<Map<String, dynamic>>('/categories/$id')).data));
  Future<void> addCategory(CategoryModel category) => _dio.post<void>('/categories', data: category.toJson());
  Future<void> editCategory(String id, CategoryModel category) => _dio.patch<void>('/categories/$id', data: category.toJson());
  Future<void> deleteCategory(String id) => _dio.delete<void>('/categories/$id');
}
