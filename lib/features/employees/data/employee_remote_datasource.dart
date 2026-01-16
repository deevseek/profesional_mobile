import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/employee_model.dart';

class EmployeeRemoteDataSource {
  EmployeeRemoteDataSource({DioClient? client}) : _client = client ?? DioClient();

  final DioClient _client;

  Future<EmployeePage> fetchEmployees({String? search, int page = 1}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/employees',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
      },
    );

    return EmployeePage.fromJson(
      _ensureMap(response.data, message: 'Invalid employees response'),
    );
  }

  Future<Employee> fetchEmployee(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/employees/$id');
    final payload = _ensureMap(response.data, message: 'Invalid employee response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Employee.fromJson(data);
    }

    return Employee.fromJson(payload);
  }

  Future<Employee> createEmployee(Employee employee) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/employees',
      data: employee.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid employee response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Employee.fromJson(data);
    }

    return Employee.fromJson(payload);
  }

  Future<Employee> updateEmployee(String id, Employee employee) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/employees/$id',
      data: employee.toPayload(),
    );
    final payload = _ensureMap(response.data, message: 'Invalid employee response');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return Employee.fromJson(data);
    }

    return Employee.fromJson(payload);
  }

  Future<void> deleteEmployee(String id) async {
    await _client.delete<void>('/employees/$id');
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
