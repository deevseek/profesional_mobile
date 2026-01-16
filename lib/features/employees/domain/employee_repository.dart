import 'employee_model.dart';

abstract class EmployeeRepository {
  Future<EmployeePage> getEmployees({
    String? search,
    int page = 1,
  });

  Future<Employee> getEmployee(String id);

  Future<Employee> createEmployee(Employee employee);

  Future<Employee> updateEmployee(String id, Employee employee);

  Future<void> deleteEmployee(String id);
}
