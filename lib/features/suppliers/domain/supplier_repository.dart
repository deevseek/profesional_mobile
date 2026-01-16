import 'supplier_model.dart';

abstract class SupplierRepository {
  Future<SupplierPage> getSuppliers({
    String? search,
    int page = 1,
  });

  Future<Supplier> getSupplier(String id);

  Future<Supplier> createSupplier(Supplier supplier);

  Future<Supplier> updateSupplier(String id, Supplier supplier);

  Future<void> deleteSupplier(String id);
}
