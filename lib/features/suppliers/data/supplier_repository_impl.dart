import '../domain/supplier_model.dart';
import '../domain/supplier_repository.dart';
import 'supplier_remote_datasource.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl({SupplierRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? SupplierRemoteDataSource();

  final SupplierRemoteDataSource _remoteDataSource;

  @override
  Future<SupplierPage> getSuppliers({
    String? search,
    int page = 1,
    int? perPage,
  }) {
    return _remoteDataSource.fetchSuppliers(search: search, page: page, perPage: perPage);
  }

  @override
  Future<Supplier> getSupplier(String id) {
    return _remoteDataSource.fetchSupplier(id);
  }

  @override
  Future<Supplier> createSupplier(Supplier supplier) {
    return _remoteDataSource.createSupplier(supplier);
  }

  @override
  Future<Supplier> updateSupplier(String id, Supplier supplier) {
    return _remoteDataSource.updateSupplier(id, supplier);
  }

  @override
  Future<void> deleteSupplier(String id) {
    return _remoteDataSource.deleteSupplier(id);
  }
}
