import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/service_item_model.dart';

class ServiceItemRemoteDataSource {
  ServiceItemRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<ServiceItemPage> fetchServiceItems({
    String? search,
    String? serviceId,
    int page = 1,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/service-items',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (serviceId != null && serviceId.trim().isNotEmpty) 'service_id': serviceId.trim(),
        'page': page,
      },
    );

    return ServiceItemPage.fromJson(
      _ensureMap(response.data, message: 'Invalid service items response'),
    );
  }

  Future<ServiceItem> fetchServiceItem(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/service-items/$id');
    final payload = _ensureMap(response.data, message: 'Invalid service item response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return ServiceItem.fromJson(data);
    }

    return ServiceItem.fromJson(payload);
  }

  Future<ServiceItem> createServiceItem(ServiceItem serviceItem) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/service-items',
      data: serviceItem.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid service item response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return ServiceItem.fromJson(data);
    }

    return ServiceItem.fromJson(payload);
  }

  Future<ServiceItem> updateServiceItem(String id, ServiceItem serviceItem) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/service-items/$id',
      data: serviceItem.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid service item response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return ServiceItem.fromJson(data);
    }

    return ServiceItem.fromJson(payload);
  }

  Future<void> deleteServiceItem(String id) async {
    await _client.delete<void>('/service-items/$id');
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
