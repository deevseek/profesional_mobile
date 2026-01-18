import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/payroll_model.dart';

class PayrollRemoteDataSource {
  PayrollRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<PayrollPage> fetchPayrolls({
    String? employee,
    String? status,
    int page = 1,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/payrolls',
      queryParameters: {
        if (employee != null && employee.trim().isNotEmpty) 'employee': employee.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        'page': page,
      },
    );

    return PayrollPage.fromJson(
      _ensureMap(response.data, message: 'Invalid payrolls response'),
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
