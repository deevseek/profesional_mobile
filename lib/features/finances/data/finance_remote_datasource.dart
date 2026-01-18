import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/finance_model.dart';

class FinanceRemoteDataSource {
  FinanceRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<FinancePage> fetchFinances({
    String? type,
    String? description,
    int page = 1,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      'finances',
      queryParameters: {
        if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'page': page,
      },
    );

    return FinancePage.fromJson(
      _ensureMap(response.data, message: 'Invalid finances response'),
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
