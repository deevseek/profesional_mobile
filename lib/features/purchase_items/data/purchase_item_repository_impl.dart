import '../domain/purchase_item_model.dart';
import '../domain/purchase_item_repository.dart';
import 'purchase_item_remote_datasource.dart';

class PurchaseItemRepositoryImpl implements PurchaseItemRepository {
  PurchaseItemRepositoryImpl({PurchaseItemRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? PurchaseItemRemoteDataSource();

  final PurchaseItemRemoteDataSource _remoteDataSource;

  @override
  Future<PurchaseItemPage> getPurchaseItems({
    String? search,
    String? purchaseId,
    String? productId,
    int? perPage,
    int page = 1,
  }) {
    return _remoteDataSource.fetchPurchaseItems(
      search: search,
      purchaseId: purchaseId,
      productId: productId,
      perPage: perPage,
      page: page,
    );
  }

  @override
  Future<PurchaseItem> getPurchaseItem(String id) {
    return _remoteDataSource.fetchPurchaseItem(id);
  }

  @override
  Future<PurchaseItem> createPurchaseItem(PurchaseItem purchaseItem) {
    return _remoteDataSource.createPurchaseItem(purchaseItem);
  }

  @override
  Future<PurchaseItem> updatePurchaseItem(String id, PurchaseItem purchaseItem) {
    return _remoteDataSource.updatePurchaseItem(id, purchaseItem);
  }

  @override
  Future<void> deletePurchaseItem(String id) {
    return _remoteDataSource.deletePurchaseItem(id);
  }
}
