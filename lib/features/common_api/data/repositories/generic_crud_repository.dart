import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';
import 'package:profesionalservis_mobile/shared/models/paginated_response.dart';
import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

final genericCrudRepositoryProvider = Provider<GenericCrudRepository>((ref) {
  return GenericCrudRepository(ref.watch(dioProvider));
});

class GenericCrudRepository {
  const GenericCrudRepository(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<ApiResourceModel>> list(
    String endpoint, {
    Map<String, dynamic> query = const <String, dynamic>{},
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(endpoint, queryParameters: query);
    return PaginatedResponse<ApiResourceModel>.fromJson(
      response.data ?? <String, dynamic>{'data': <dynamic>[]},
      ApiResourceModel.fromJson,
    );
  }

  Future<ApiResourceModel> detail(String endpoint, String id) async {
    final response = await _dio.get<Map<String, dynamic>>('$endpoint/$id');
    return ApiResourceModel.fromJson(unwrapDataMap(response.data));
  }

  Future<ApiResourceModel> create(String endpoint, Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(endpoint, data: payload);
    return ApiResourceModel.fromJson(unwrapDataMap(response.data));
  }

  Future<ApiResourceModel> update(String endpoint, String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Map<String, dynamic>>('$endpoint/$id', data: payload);
    return ApiResourceModel.fromJson(unwrapDataMap(response.data));
  }

  Future<void> delete(String endpoint, String id) async {
    await _dio.delete<void>('$endpoint/$id');
  }

  Future<Map<String, dynamic>> postAction(String endpoint, Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(endpoint, data: payload);
    return response.data ?? <String, dynamic>{};
  }
}
