import '../domain/employee_model.dart';
import '../domain/employee_repository.dart';
import 'employee_remote_datasource.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  EmployeeRepositoryImpl({EmployeeRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? EmployeeRemoteDataSource();

  final EmployeeRemoteDataSource _remoteDataSource;

  @override
  Future<EmployeePage> getEmployees({String? search, int page = 1}) {
    return _remoteDataSource.fetchEmployees(search: search, page: page);
  }

  @override
  Future<Employee> getEmployee(String id) {
    return _remoteDataSource.fetchEmployee(id);
  }

  @override
  Future<Employee> createEmployee(Employee employee) {
    return _remoteDataSource.createEmployee(employee);
  }

  @override
  Future<Employee> updateEmployee(String id, Employee employee) {
    return _remoteDataSource.updateEmployee(id, employee);
  }

  @override
  Future<void> deleteEmployee(String id) {
    return _remoteDataSource.deleteEmployee(id);
  }
}
