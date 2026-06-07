import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/supplier/data/models/supplier_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';
import 'package:profesionalservis_mobile/shared/models/paginated_response.dart';
import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) => SupplierRepository(ref.watch(dioProvider)));
class SupplierRepository {
  const SupplierRepository(this._dio);
  final Dio _dio;
  Future<PaginatedResponse<SupplierModel>> getSuppliers({int page = 1, String? search}) async => PaginatedResponse.fromJson((await _dio.get<Map<String, dynamic>>('/suppliers', queryParameters: {'page': page, if (search != null && search.isNotEmpty) 'search': search})).data ?? {}, SupplierModel.fromJson);
  Future<SupplierModel> getSupplier(String id) async => SupplierModel.fromJson(unwrapDataMap((await _dio.get<Map<String, dynamic>>('/suppliers/$id')).data));
  Future<void> addSupplier(SupplierModel supplier) => _dio.post<void>('/suppliers', data: supplier.toJson());
  Future<void> editSupplier(String id, SupplierModel supplier) => _dio.patch<void>('/suppliers/$id', data: supplier.toJson());
  Future<void> deleteSupplier(String id) => _dio.delete<void>('/suppliers/$id');
}
