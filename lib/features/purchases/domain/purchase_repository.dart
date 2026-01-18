import 'purchase_model.dart';

abstract class PurchaseRepository {
  Future<PurchasePage> getPurchases({
    String? search,
    int page = 1,
  });

  Future<Purchase> getPurchase(String id);

  Future<Purchase> createPurchase(Purchase purchase);

  Future<Purchase> updatePurchase(String id, Map<String, dynamic> payload);
}
