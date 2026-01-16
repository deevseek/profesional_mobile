import '../domain/service_model.dart';
import '../domain/service_repository.dart';
import 'service_remote_datasource.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl({ServiceRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ServiceRemoteDataSource();

  final ServiceRemoteDataSource _remoteDataSource;

  @override
  Future<ServicePage> getServices({String? customerName, String? status, int page = 1}) {
    return _remoteDataSource.fetchServices(
      customerName: customerName,
      status: status,
      page: page,
    );
  }

  @override
  Future<Service> getService(String id) {
    return _remoteDataSource.fetchService(id);
  }

  @override
  Future<Service> createService(Service service) {
    return _remoteDataSource.createService(service);
  }

  @override
  Future<Service> updateService(String id, Service service) {
    return _remoteDataSource.updateService(id, service);
  }

  @override
  Future<void> deleteService(String id) {
    return _remoteDataSource.deleteService(id);
  }
}
