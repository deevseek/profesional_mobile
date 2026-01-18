import 'finance_model.dart';

abstract class FinanceRepository {
  Future<FinancePage> getFinances({
    String? type,
    String? description,
    int page = 1,
  });
}
