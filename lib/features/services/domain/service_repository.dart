import 'service_model.dart';

abstract class ServiceRepository {
  Future<ServicePage> getServices({
    String? customerName,
    String? status,
    int page = 1,
  });

  Future<Service> getService(String id);

  Future<Service> createService(Service service);

  Future<Service> updateService(String id, Service service);

  Future<void> deleteService(String id);
}
