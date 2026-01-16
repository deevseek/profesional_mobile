import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/service_log_model.dart';

class ServiceLogRemoteDataSource {
  ServiceLogRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<ServiceLogPage> fetchServiceLogs({
    String? search,
    String? serviceId,
    String? status,
    int page = 1,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/service-logs',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (serviceId != null && serviceId.trim().isNotEmpty) 'service_id': serviceId.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        'page': page,
      },
    );

    return ServiceLogPage.fromJson(
      _ensureMap(response.data, message: 'Invalid service logs response'),
    );
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
