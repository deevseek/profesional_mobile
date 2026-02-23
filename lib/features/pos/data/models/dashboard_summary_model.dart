class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.todayRevenue,
    required this.todayTransactions,
    required this.totalProducts,
    required this.totalCustomers,
    required this.presentEmployees,
  });

  final double todayRevenue;
  final int todayTransactions;
  final int totalProducts;
  final int totalCustomers;
  final int presentEmployees;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ??
          (json['today_revenue'] as num?)?.toDouble() ??
          0,
      todayTransactions: (json['todayTransactions'] as num?)?.toInt() ??
          (json['today_transactions'] as num?)?.toInt() ??
          0,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ??
          (json['total_products'] as num?)?.toInt() ??
          0,
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ??
          (json['total_customers'] as num?)?.toInt() ??
          0,
      presentEmployees: (json['presentEmployees'] as num?)?.toInt() ??
          (json['present_employees'] as num?)?.toInt() ??
          0,
    );
  }
}
