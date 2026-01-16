import 'service_log_model.dart';

abstract class ServiceLogRepository {
  Future<ServiceLogPage> getServiceLogs({
    String? search,
    String? serviceId,
    String? status,
    int page = 1,
  });
}
