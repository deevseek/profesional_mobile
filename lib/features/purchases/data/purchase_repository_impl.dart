import '../domain/purchase_model.dart';
import '../domain/purchase_repository.dart';
import 'purchase_remote_datasource.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl({PurchaseRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? PurchaseRemoteDataSource();

  final PurchaseRemoteDataSource _remoteDataSource;

  @override
  Future<PurchasePage> getPurchases({String? search, int page = 1}) {
    return _remoteDataSource.fetchPurchases(search: search, page: page);
  }

  @override
  Future<Purchase> getPurchase(String id) {
    return _remoteDataSource.fetchPurchase(id);
  }

  @override
  Future<Purchase> createPurchase(Purchase purchase) {
    return _remoteDataSource.createPurchase(purchase);
  }

  @override
  Future<Purchase> updatePurchase(String id, Map<String, dynamic> payload) {
    return _remoteDataSource.updatePurchase(id, payload);
  }
}
