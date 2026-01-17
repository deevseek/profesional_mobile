import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/supplier_model.dart';

class SupplierRemoteDataSource {
  SupplierRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<SupplierPage> fetchSuppliers({
    String? search,
    int page = 1,
    int? perPage,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      'suppliers',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        if (perPage != null) 'per_page': perPage,
      },
    );

    return SupplierPage.fromJson(_ensureMap(response.data, message: 'Invalid suppliers response'));
  }

  Future<Supplier> fetchSupplier(String id) async {
    final response = await _client.get<Map<String, dynamic>>('suppliers/$id');
    final payload = _ensureMap(response.data, message: 'Invalid supplier response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Supplier.fromJson(data);
    }

    return Supplier.fromJson(payload);
  }

  Future<Supplier> createSupplier(Supplier supplier) async {
    final response = await _client.post<Map<String, dynamic>>(
      'suppliers',
      data: supplier.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid supplier response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Supplier.fromJson(data);
    }

    return Supplier.fromJson(payload);
  }

  Future<Supplier> updateSupplier(String id, Supplier supplier) async {
    final response = await _client.patch<Map<String, dynamic>>(
      'suppliers/$id',
      data: supplier.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid supplier response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Supplier.fromJson(data);
    }

    return Supplier.fromJson(payload);
  }

  Future<void> deleteSupplier(String id) async {
    await _client.delete<void>('suppliers/$id');
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
