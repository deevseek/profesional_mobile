import 'purchase_item_model.dart';

abstract class PurchaseItemRepository {
  Future<PurchaseItemPage> getPurchaseItems({
    String? search,
    String? purchaseId,
    String? productId,
    int? perPage,
    int page = 1,
  });

  Future<PurchaseItem> getPurchaseItem(String id);

  Future<PurchaseItem> createPurchaseItem(PurchaseItem purchaseItem);

  Future<PurchaseItem> updatePurchaseItem(String id, PurchaseItem purchaseItem);

  Future<void> deletePurchaseItem(String id);
}
