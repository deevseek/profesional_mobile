import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/customer_model.dart';

class CustomerRemoteDataSource {
  CustomerRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<CustomerPage> fetchCustomers({String? search, int page = 1, int? perPage}) async {
    final response = await _client.get<Map<String, dynamic>>(
      'customers',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        if (perPage != null) 'per_page': perPage,
      },
    );

    return CustomerPage.fromJson(_ensureMap(response.data, message: 'Invalid customers response'));
  }

  Future<Customer> fetchCustomer(String id) async {
    final response = await _client.get<Map<String, dynamic>>('customers/$id');
    final payload = _ensureMap(response.data, message: 'Invalid customer response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Customer.fromJson(data);
    }

    return Customer.fromJson(payload);
  }

  Future<Customer> createCustomer(Customer customer) async {
    final response = await _client.post<Map<String, dynamic>>(
      'customers',
      data: customer.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid customer response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Customer.fromJson(data);
    }

    return Customer.fromJson(payload);
  }

  Future<Customer> updateCustomer(String id, Customer customer) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/customers/$id',
      data: customer.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid customer response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Customer.fromJson(data);
    }

    return Customer.fromJson(payload);
  }

  Future<void> deleteCustomer(String id) async {
    await _client.delete<void>('customers/$id');
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
