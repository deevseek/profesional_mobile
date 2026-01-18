import '../domain/payroll_model.dart';
import '../domain/payroll_repository.dart';
import 'payroll_remote_datasource.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  PayrollRepositoryImpl({PayrollRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? PayrollRemoteDataSource();

  final PayrollRemoteDataSource _remoteDataSource;

  @override
  Future<PayrollPage> getPayrolls({
    String? employee,
    String? status,
    int page = 1,
  }) {
    return _remoteDataSource.fetchPayrolls(
      employee: employee,
      status: status,
      page: page,
    );
  }
}
