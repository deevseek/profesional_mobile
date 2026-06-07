import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/common_api/data/repositories/generic_crud_repository.dart';

final warrantyClaimRepositoryProvider = Provider<WarrantyClaimRepository>((ref) => WarrantyClaimRepository(ref.watch(genericCrudRepositoryProvider)));

class WarrantyClaimRepository {
  const WarrantyClaimRepository(this._crud);
  final GenericCrudRepository _crud;
  static const endpoint = '/warranty-claims';
  Future<dynamic> list({int page = 1, String? search, Map<String, dynamic> filters = const {}}) => _crud.list(endpoint, query: {'page': page, if (search != null && search.isNotEmpty) 'search': search, ...filters});
  Future<dynamic> detail(String id) => _crud.detail(endpoint, id);
  Future<dynamic> create(Map<String, dynamic> payload) => _crud.create(endpoint, payload);
  Future<dynamic> update(String id, Map<String, dynamic> payload) => _crud.update(endpoint, id, payload);
  Future<void> delete(String id) => _crud.delete(endpoint, id);
}
