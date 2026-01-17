import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/customer_model.dart';

/// Remote data source for Customer API operations
/// 
/// Implements all CRUD operations according to API documentation:
/// - GET /customers (list with pagination and search)
/// - GET /customers/{id} (detail)
/// - POST /customers (create)
/// - PATCH /customers/{id} (update)
/// - DELETE /customers/{id} (delete)
class CustomerRemoteDataSource {
  CustomerRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  /// Fetch customers list with optional search and pagination
  /// 
  /// Query parameters:
  /// - search: optional, searches in name, email, phone
  /// - page: current page (1-based)
  /// - per_page: items per page (API default: 15)
  /// 
  /// Returns CustomerPage with data, meta, and links
  Future<CustomerPage> fetchCustomers({String? search, int page = 1, int? perPage}) async {
    if (kDebugMode) {
      print('🔵 [CUSTOMER] fetchCustomers - search: $search, page: $page, perPage: $perPage');
    }
    
    final response = await _client.get<Map<String, dynamic>>(
      '/customers',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        if (perPage != null) 'per_page': perPage,
      },
    );

    if (kDebugMode) {
      print('🟢 [CUSTOMER] Response: ${response.data}');
    }

    final data = response.data;
    if (data == null) {
      throw ApiException('Empty response from server');
    }

    // Handle case where API returns bare list instead of wrapped object
    if (data is List) {
      return CustomerPage.fromJson({'data': data});
    }

    return CustomerPage.fromJson(_ensureMap(data, message: 'Invalid customers response'));
  }

  /// Fetch single customer by ID
  /// 
  /// API Response: `{ "data": {...} }`
  Future<Customer> fetchCustomer(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/customers/$id');
    final payload = _ensureMap(response.data, message: 'Invalid customer response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Customer.fromJson(data);
    }

    return Customer.fromJson(payload);
  }

  /// Create new customer
  /// 
  /// Request Body:
  /// ```json
  /// {
  ///   "name": "string (required)",
  ///   "email": "string (optional, unique)",
  ///   "phone": "string (optional)",
  ///   "address": "string (optional)"
  /// }
  /// ```
  /// 
  /// API Response (201): `{ "data": {...} }`
  Future<Customer> createCustomer(Customer customer) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/customers',
      data: customer.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid customer response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Customer.fromJson(data);
    }

    return Customer.fromJson(payload);
  }

  /// Update existing customer (partial update)
  /// 
  /// Only non-null fields are sent in request
  /// 
  /// API Response (200): `{ "data": {...} }`
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

  /// Delete customer by ID
  /// 
  /// API Response (200): `{ "message": "Deleted." }`
  Future<void> deleteCustomer(String id) async {
    await _client.delete<void>('/customers/$id');
  }

  /// Ensure dynamic data is a Map<String, dynamic>
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
