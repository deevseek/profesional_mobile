import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/service_model.dart';

class ServiceRemoteDataSource {
  ServiceRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<ServicePage> fetchServices({
    String? customerName,
    String? status,
    int page = 1,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      'services',
      queryParameters: {
        if (customerName != null && customerName.trim().isNotEmpty)
          'customer_name': customerName.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        'page': page,
      },
    );

    return ServicePage.fromJson(_ensureMap(response.data, message: 'Invalid services response'));
  }

  Future<Service> fetchService(String id) async {
    final response = await _client.get<Map<String, dynamic>>('services/$id');
    final payload = _ensureMap(response.data, message: 'Invalid service response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Service.fromJson(data);
    }

    return Service.fromJson(payload);
  }

  Future<Service> createService(Service service) async {
    final response = await _client.post<Map<String, dynamic>>(
      'services',
      data: service.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid service response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Service.fromJson(data);
    }

    return Service.fromJson(payload);
  }

  Future<Service> updateService(String id, Service service) async {
    final response = await _client.patch<Map<String, dynamic>>(
      'services/$id',
      data: service.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid service response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Service.fromJson(data);
    }

    return Service.fromJson(payload);
  }

  Future<void> deleteService(String id) async {
    await _client.delete<void>('services/$id');
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
