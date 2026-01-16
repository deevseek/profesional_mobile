import 'customer_model.dart';

abstract class CustomerRepository {
  Future<CustomerPage> getCustomers({
    String? search,
    int page = 1,
  });

  Future<Customer> getCustomer(String id);

  Future<Customer> createCustomer(Customer customer);

  Future<Customer> updateCustomer(String id, Customer customer);

  Future<void> deleteCustomer(String id);
}
