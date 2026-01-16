import 'service_item_model.dart';

abstract class ServiceItemRepository {
  Future<ServiceItemPage> getServiceItems({
    String? search,
    String? serviceId,
    int page = 1,
  });

  Future<ServiceItem> getServiceItem(String id);

  Future<ServiceItem> createServiceItem(ServiceItem serviceItem);

  Future<ServiceItem> updateServiceItem(String id, ServiceItem serviceItem);

  Future<void> deleteServiceItem(String id);
}
