import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/customer/data/models/customer_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';
import 'package:profesionalservis_mobile/shared/models/paginated_response.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(dioProvider));
});

class CustomerRepository {
  const CustomerRepository(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<CustomerModel>> getCustomers({
    required int page,
    String? search,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/customers',
      queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Response pelanggan kosong.');
    }

    return PaginatedResponse<CustomerModel>.fromJson(data, CustomerModel.fromJson);
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _dio.post<void>('/customers', data: _toPayload(customer));
  }

  Future<void> editCustomer({
    required String id,
    required CustomerModel customer,
  }) async {
    await _dio.patch<void>('/customers/$id', data: _toPayload(customer));
  }

  Future<void> deleteCustomer(String id) async {
    await _dio.delete<void>('/customers/$id');
  }

  Map<String, dynamic> _toPayload(CustomerModel customer) {
    return {
      'name': customer.name,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
      'notes': customer.notes,
    };
  }
}
