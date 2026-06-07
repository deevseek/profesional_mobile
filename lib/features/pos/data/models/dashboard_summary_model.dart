import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.todaySales,
    required this.monthlySales,
    required this.transactionsToday,
    required this.customersCount,
    required this.productsCount,
    required this.activeServicesCount,
    required this.outstandingPurchases,
    required this.recentTransactions,
    required this.recentServices,
    required this.financeLabels,
    required this.financeIncome,
    required this.financeExpense,
  });

  final double todaySales;
  final double monthlySales;
  final int transactionsToday;
  final int customersCount;
  final int productsCount;
  final int activeServicesCount;
  final double outstandingPurchases;
  final List<Map<String, dynamic>> recentTransactions;
  final List<Map<String, dynamic>> recentServices;
  final List<String> financeLabels;
  final List<double> financeIncome;
  final List<double> financeExpense;

  double get todayRevenue => todaySales;
  int get todayTransactions => transactionsToday;
  int get totalProducts => productsCount;
  int get totalCustomers => customersCount;
  int get presentEmployees => activeServicesCount;

  bool get isEmpty => todaySales == 0 && monthlySales == 0 && transactionsToday == 0 && customersCount == 0 && productsCount == 0 && activeServicesCount == 0;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = unwrapDataMap(json);
    final chart = parseMap(data['finance_chart']);
    return DashboardSummaryModel(
      todaySales: parseDouble(data['today_sales'] ?? data['todayRevenue'] ?? data['today_revenue']),
      monthlySales: parseDouble(data['monthly_sales'] ?? data['month_sales']),
      transactionsToday: parseInt(data['transactions_today'] ?? data['todayTransactions'] ?? data['today_transactions']),
      customersCount: parseInt(data['customers_count'] ?? data['totalCustomers'] ?? data['total_customers']),
      productsCount: parseInt(data['products_count'] ?? data['totalProducts'] ?? data['total_products']),
      activeServicesCount: parseInt(data['active_services_count'] ?? data['presentEmployees'] ?? data['present_employees']),
      outstandingPurchases: parseDouble(data['outstanding_purchases']),
      recentTransactions: parseMapList(data['recent_transactions']),
      recentServices: parseMapList(data['recent_services']),
      financeLabels: chart['labels'] is List ? (chart['labels'] as List).map(parseString).toList(growable: false) : const <String>[],
      financeIncome: chart['income'] is List ? (chart['income'] as List).map(parseDouble).toList(growable: false) : const <double>[],
      financeExpense: chart['expense'] is List ? (chart['expense'] as List).map(parseDouble).toList(growable: false) : const <double>[],
    );
  }
}
