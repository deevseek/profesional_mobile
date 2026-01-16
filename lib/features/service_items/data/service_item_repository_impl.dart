import '../domain/service_item_model.dart';
import '../domain/service_item_repository.dart';
import 'service_item_remote_datasource.dart';

class ServiceItemRepositoryImpl implements ServiceItemRepository {
  ServiceItemRepositoryImpl({ServiceItemRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ServiceItemRemoteDataSource();

  final ServiceItemRemoteDataSource _remoteDataSource;

  @override
  Future<ServiceItemPage> getServiceItems({
    String? search,
    String? serviceId,
    int page = 1,
  }) {
    return _remoteDataSource.fetchServiceItems(
      search: search,
      serviceId: serviceId,
      page: page,
    );
  }

  @override
  Future<ServiceItem> getServiceItem(String id) {
    return _remoteDataSource.fetchServiceItem(id);
  }

  @override
  Future<ServiceItem> createServiceItem(ServiceItem serviceItem) {
    return _remoteDataSource.createServiceItem(serviceItem);
  }

  @override
  Future<ServiceItem> updateServiceItem(String id, ServiceItem serviceItem) {
    return _remoteDataSource.updateServiceItem(id, serviceItem);
  }

  @override
  Future<void> deleteServiceItem(String id) {
    return _remoteDataSource.deleteServiceItem(id);
  }
}
