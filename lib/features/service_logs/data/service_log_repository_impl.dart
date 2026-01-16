import '../domain/service_log_model.dart';
import '../domain/service_log_repository.dart';
import 'service_log_remote_datasource.dart';

class ServiceLogRepositoryImpl implements ServiceLogRepository {
  ServiceLogRepositoryImpl({ServiceLogRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ServiceLogRemoteDataSource();

  final ServiceLogRemoteDataSource _remoteDataSource;

  @override
  Future<ServiceLogPage> getServiceLogs({
    String? search,
    String? serviceId,
    String? status,
    int page = 1,
  }) {
    return _remoteDataSource.fetchServiceLogs(
      search: search,
      serviceId: serviceId,
      status: status,
      page: page,
    );
  }
}
