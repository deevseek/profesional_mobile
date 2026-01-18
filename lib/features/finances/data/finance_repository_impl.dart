import '../domain/finance_model.dart';
import '../domain/finance_repository.dart';
import 'finance_remote_datasource.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl({FinanceRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FinanceRemoteDataSource();

  final FinanceRemoteDataSource _remoteDataSource;

  @override
  Future<FinancePage> getFinances({
    String? type,
    String? description,
    int page = 1,
  }) {
    return _remoteDataSource.fetchFinances(
      type: type,
      description: description,
      page: page,
    );
  }
}
