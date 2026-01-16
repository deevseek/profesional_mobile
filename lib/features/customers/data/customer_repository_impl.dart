import '../domain/customer_model.dart';
import '../domain/customer_repository.dart';
import 'customer_remote_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl({CustomerRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CustomerRemoteDataSource();

  final CustomerRemoteDataSource _remoteDataSource;

  @override
  Future<CustomerPage> getCustomers({String? search, int page = 1}) {
    return _remoteDataSource.fetchCustomers(search: search, page: page);
  }

  @override
  Future<Customer> getCustomer(String id) {
    return _remoteDataSource.fetchCustomer(id);
  }

  @override
  Future<Customer> createCustomer(Customer customer) {
    return _remoteDataSource.createCustomer(customer);
  }

  @override
  Future<Customer> updateCustomer(String id, Customer customer) {
    return _remoteDataSource.updateCustomer(id, customer);
  }

  @override
  Future<void> deleteCustomer(String id) {
    return _remoteDataSource.deleteCustomer(id);
  }
}
