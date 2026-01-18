import 'payroll_model.dart';

abstract class PayrollRepository {
  Future<PayrollPage> getPayrolls({
    String? employee,
    String? status,
    int page = 1,
  });
}
