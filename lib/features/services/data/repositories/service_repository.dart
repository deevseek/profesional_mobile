import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_model.dart';
import 'package:profesionalservis_mobile/features/services/domain/service_payloads.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';
import 'package:profesionalservis_mobile/shared/models/paginated_response.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(ref.watch(dioProvider));
});

class ServiceRepository {
  const ServiceRepository(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<ServiceModel>> getServices({
    required int page,
    String? search,
    String? status,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/services',
      queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final body = response.data;
    if (body == null) {
      throw const FormatException('Data services kosong.');
    }

    return PaginatedResponse<ServiceModel>.fromJson(body, ServiceModel.fromJson);
  }

  Future<ServiceModel> createService(CreateServicePayload payload) async {
    final response = await _dio.post<Map<String, dynamic>>('/services', data: payload.toJson());
    return _unwrapServiceData(response.data);
  }

  Future<ServiceModel> getServiceDetail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/services/$id');
    return _unwrapServiceData(response.data);
  }

  Future<ServiceModel> updateService(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Map<String, dynamic>>('/services/$id', data: payload);
    return _unwrapServiceData(response.data);
  }

  Future<void> deleteService(String id) async {
    await _dio.delete<void>('/services/$id');
  }

  Future<ServiceModel> addServiceItem(String serviceId, AddServiceItemPayload payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/services/$serviceId/items',
      data: payload.toJson(),
    );
    return _unwrapServiceData(response.data);
  }

  Future<ServiceModel> deleteServiceItem(String serviceId, String itemId) async {
    final response = await _dio.delete<Map<String, dynamic>>('/services/$serviceId/items/$itemId');
    return _unwrapServiceData(response.data);
  }

  ServiceModel _unwrapServiceData(Map<String, dynamic>? body) {
    if (body == null) {
      throw const FormatException('Response tidak valid.');
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Format response service tidak valid.');
    }
    return ServiceModel.fromJson(data);
  }
}
