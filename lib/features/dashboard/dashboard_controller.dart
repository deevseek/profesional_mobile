import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.fetchSummary();
});

final dashboardOverviewProvider = Provider<AsyncValue<DashboardOverviewData>>((ref) {
  final summary = ref.watch(dashboardSummaryProvider);
  return summary.whenData((data) => data.toOverviewData());
});

final dashboardRecentActivityProvider = Provider<AsyncValue<DashboardRecentActivityData>>((ref) {
  final summary = ref.watch(dashboardSummaryProvider);
  return summary.whenData((data) => data.toRecentActivityData());
});

class DashboardRepository {
  DashboardRepository({
    DioClient? client,
  }) : _client = client ?? DioClient();

  final DioClient _client;

  Future<DashboardSummary> fetchSummary({int days = 7}) async {
    final safeDays = days < 1 ? 1 : days;
    final response = await _client.get<Map<String, dynamic>>(
      '/dashboard/summary',
      queryParameters: {'days': safeDays},
    );

    final payload = _ensureMap(response.data, message: 'Invalid dashboard summary response');
    final data = payload['data'];
    if (data is Map) {
      return DashboardSummary.fromJson(
        data.map((key, value) => MapEntry('$key', value)),
      );
    }
    throw Exception('Invalid dashboard summary response');
  }
}

class DashboardOverviewData {
  const DashboardOverviewData({
    required this.todaySales,
    required this.monthlySales,
    required this.transactionsToday,
    required this.totalCustomers,
    required this.totalProducts,
    required this.activeServices,
    required this.outstandingPurchases,
  });

  final int todaySales;
  final int monthlySales;
  final int transactionsToday;
  final int totalCustomers;
  final int totalProducts;
  final int activeServices;
  final int outstandingPurchases;
}

class DashboardRecentActivityData {
  const DashboardRecentActivityData({
    required this.recentServices,
    required this.recentTransactions,
  });

  final List<RecentActivityItem> recentServices;
  final List<RecentActivityItem> recentTransactions;
}

class RecentActivityItem {
  const RecentActivityItem({
    required this.title,
    required this.subtitle,
    this.status,
    this.timestamp,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String? status;
  final DateTime? timestamp;
  final IconData icon;
  final Color color;
}

class DashboardSummary {
  const DashboardSummary({
    required this.todaySales,
    required this.monthlySales,
    required this.transactionsToday,
    required this.customersCount,
    required this.productsCount,
    required this.activeServicesCount,
    required this.outstandingPurchases,
    required this.recentTransactions,
    required this.recentServices,
  });

  final int todaySales;
  final int monthlySales;
  final int transactionsToday;
  final int customersCount;
  final int productsCount;
  final int activeServicesCount;
  final int outstandingPurchases;
  final List<DashboardTransactionSummary> recentTransactions;
  final List<DashboardServiceSummary> recentServices;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final transactions = json['recent_transactions'];
    final services = json['recent_services'];
    return DashboardSummary(
      todaySales: _asInt(json['today_sales']) ?? 0,
      monthlySales: _asInt(json['monthly_sales']) ?? 0,
      transactionsToday: _asInt(json['transactions_today']) ?? 0,
      customersCount: _asInt(json['customers_count']) ?? 0,
      productsCount: _asInt(json['products_count']) ?? 0,
      activeServicesCount: _asInt(json['active_services_count']) ?? 0,
      outstandingPurchases: _asInt(json['outstanding_purchases']) ?? 0,
      recentTransactions: transactions is List
          ? transactions
              .whereType<Map>()
              .map((item) => DashboardTransactionSummary.fromJson(
                    item.map((key, value) => MapEntry('$key', value)),
                  ))
              .toList()
          : const [],
      recentServices: services is List
          ? services
              .whereType<Map>()
              .map((item) => DashboardServiceSummary.fromJson(
                    item.map((key, value) => MapEntry('$key', value)),
                  ))
              .toList()
          : const [],
    );
  }

  DashboardOverviewData toOverviewData() {
    return DashboardOverviewData(
      todaySales: todaySales,
      monthlySales: monthlySales,
      transactionsToday: transactionsToday,
      totalCustomers: customersCount,
      totalProducts: productsCount,
      activeServices: activeServicesCount,
      outstandingPurchases: outstandingPurchases,
    );
  }

  DashboardRecentActivityData toRecentActivityData({int limit = 5}) {
    final services = recentServices
        .take(limit)
        .map(
          (service) => RecentActivityItem(
            title: service.device.isNotEmpty ? service.device : 'Service',
            subtitle: service.customerName ?? 'Customer',
            status: service.status,
            timestamp: service.createdAt,
            icon: Icons.build_circle_outlined,
            color: Colors.indigo,
          ),
        )
        .toList();

    final transactions = recentTransactions
        .take(limit)
        .map(
          (transaction) => RecentActivityItem(
            title: transaction.invoiceNumber.isNotEmpty
                ? transaction.invoiceNumber
                : 'Invoice',
            subtitle: transaction.customerName ?? 'Customer',
            status: null,
            timestamp: transaction.createdAt,
            icon: Icons.receipt_long_outlined,
            color: Colors.teal,
          ),
        )
        .toList();

    return DashboardRecentActivityData(
      recentServices: services,
      recentTransactions: transactions,
    );
  }
}

class DashboardTransactionSummary {
  const DashboardTransactionSummary({
    required this.id,
    required this.invoiceNumber,
    required this.total,
    required this.customerName,
    required this.createdAt,
  });

  final int id;
  final String invoiceNumber;
  final int total;
  final String? customerName;
  final DateTime? createdAt;

  factory DashboardTransactionSummary.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'];
    return DashboardTransactionSummary(
      id: _asInt(json['id']) ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      total: _asInt(json['total']) ?? 0,
      customerName: _extractName(customer),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class DashboardServiceSummary {
  const DashboardServiceSummary({
    required this.id,
    required this.device,
    required this.status,
    required this.customerName,
    required this.createdAt,
  });

  final int id;
  final String device;
  final String? status;
  final String? customerName;
  final DateTime? createdAt;

  factory DashboardServiceSummary.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'];
    return DashboardServiceSummary(
      id: _asInt(json['id']) ?? 0,
      device: json['device']?.toString() ?? '',
      status: json['status']?.toString(),
      customerName: _extractName(customer),
      createdAt: _parseDate(json['created_at']),
    );
  }
}

Map<String, dynamic> _ensureMap(
  dynamic data, {
  required String message,
}) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map) {
    return data.map((key, value) => MapEntry('$key', value));
  }
  throw Exception(message);
}

int? _asInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  return int.tryParse(value.toString());
}

String? _extractName(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Map) {
    final name = value['name'] ?? value['full_name'] ?? value['email'];
    return name?.toString();
  }
  return value.toString();
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  final parsed = DateTime.tryParse(value.toString());
  return parsed?.toLocal();
}
