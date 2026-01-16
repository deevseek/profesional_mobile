import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../customers/data/customer_repository_impl.dart';
import '../customers/domain/customer_model.dart';
import '../services/data/service_repository_impl.dart';
import '../services/domain/service_model.dart';
import '../transactions/data/transaction_repository_impl.dart';
import '../transactions/domain/transaction_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardOverviewProvider = FutureProvider<DashboardOverviewData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.fetchOverview();
});

final dashboardRecentActivityProvider = FutureProvider<DashboardRecentActivityData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.fetchRecentActivity();
});

class DashboardRepository {
  DashboardRepository({
    CustomerRepositoryImpl? customerRepository,
    ServiceRepositoryImpl? serviceRepository,
    TransactionRepositoryImpl? transactionRepository,
    DioClient? client,
  })  : _customerRepository = customerRepository ?? CustomerRepositoryImpl(),
        _serviceRepository = serviceRepository ?? ServiceRepositoryImpl(),
        _transactionRepository = transactionRepository ?? TransactionRepositoryImpl(),
        _client = client ?? DioClient();

  final CustomerRepositoryImpl _customerRepository;
  final ServiceRepositoryImpl _serviceRepository;
  final TransactionRepositoryImpl _transactionRepository;
  final DioClient _client;

  Future<DashboardOverviewData> fetchOverview() async {
    final today = DateTime.now();
    final results = await Future.wait([
      _customerRepository.getCustomers(page: 1),
      _serviceRepository.getServices(status: 'active', page: 1),
      _transactionRepository.getTransactions(page: 1),
      _fetchAttendanceLogs(page: 1),
      _fetchCashSessionsTotal(),
    ]);

    final customersPage = results[0] as CustomerPage;
    final servicesPage = results[1] as ServicePage;
    final transactionsPage = results[2] as TransactionPage;
    final attendancePage = results[3] as _GenericPage;
    final openCashSessions = results[4] as int;

    final transactionsToday = transactionsPage.data
        .where((transaction) => _isToday(transaction.createdAt, today))
        .length;

    final attendanceToday = attendancePage.items
        .map(AttendanceLogEntry.fromJson)
        .where((entry) => _isToday(entry.timestamp, today))
        .length;

    return DashboardOverviewData(
      totalCustomers: customersPage.meta.total,
      activeServices: servicesPage.meta.total,
      attendanceToday: attendanceToday,
      transactionsToday: transactionsToday,
      openCashSessions: openCashSessions,
    );
  }

  Future<DashboardRecentActivityData> fetchRecentActivity({int limit = 5}) async {
    final results = await Future.wait([
      _serviceRepository.getServices(page: 1),
      _transactionRepository.getTransactions(page: 1),
      _fetchAttendanceLogs(page: 1),
    ]);

    final servicesPage = results[0] as ServicePage;
    final transactionsPage = results[1] as TransactionPage;
    final attendancePage = results[2] as _GenericPage;

    final recentServices = servicesPage.data
        .take(limit)
        .map(
          (service) => RecentActivityItem(
            title: service.title?.trim().isNotEmpty == true
                ? service.title!
                : service.customerName,
            subtitle: service.customerName,
            status: service.status,
            timestamp: service.createdAt ?? service.scheduledAt,
            icon: Icons.build_circle_outlined,
            color: Colors.indigo,
          ),
        )
        .toList();

    final recentTransactions = transactionsPage.data
        .take(limit)
        .map(
          (transaction) => RecentActivityItem(
            title: transaction.invoiceNumber,
            subtitle: transaction.customerName ?? 'Customer',
            status: transaction.status,
            timestamp: transaction.createdAt,
            icon: Icons.receipt_long_outlined,
            color: Colors.teal,
          ),
        )
        .toList();

    final recentAttendance = attendancePage.items
        .map(AttendanceLogEntry.fromJson)
        .take(limit)
        .map(
          (entry) => RecentActivityItem(
            title: entry.employeeName ?? 'Attendance',
            subtitle: entry.status ?? 'Check',
            status: entry.status,
            timestamp: entry.timestamp,
            icon: Icons.fingerprint_outlined,
            color: Colors.deepPurple,
          ),
        )
        .toList();

    return DashboardRecentActivityData(
      recentServices: recentServices,
      recentTransactions: recentTransactions,
      recentAttendanceLogs: recentAttendance,
    );
  }

  Future<_GenericPage> _fetchAttendanceLogs({int page = 1}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/attendance-logs',
      queryParameters: {'page': page},
    );

    return _GenericPage.fromJson(
      _ensureMap(response.data, message: 'Invalid attendance logs response'),
    );
  }

  Future<int> _fetchCashSessionsTotal() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/cash-sessions',
      queryParameters: {'status': 'open', 'page': 1},
    );

    final payload = _ensureMap(response.data, message: 'Invalid cash sessions response');
    return _extractTotal(payload);
  }

  bool _isToday(DateTime? value, DateTime today) {
    if (value == null) {
      return false;
    }
    return DateUtils.isSameDay(value, today);
  }

  int _extractTotal(Map<String, dynamic> payload) {
    final meta = payload['meta'];
    if (meta is Map) {
      final total = meta['total'];
      return _asInt(total) ?? 0;
    }
    final total = payload['total'];
    return _asInt(total) ?? 0;
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
}

class DashboardOverviewData {
  const DashboardOverviewData({
    required this.totalCustomers,
    required this.activeServices,
    required this.attendanceToday,
    required this.transactionsToday,
    required this.openCashSessions,
  });

  final int totalCustomers;
  final int activeServices;
  final int attendanceToday;
  final int transactionsToday;
  final int openCashSessions;
}

class DashboardRecentActivityData {
  const DashboardRecentActivityData({
    required this.recentServices,
    required this.recentTransactions,
    required this.recentAttendanceLogs,
  });

  final List<RecentActivityItem> recentServices;
  final List<RecentActivityItem> recentTransactions;
  final List<RecentActivityItem> recentAttendanceLogs;
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

class AttendanceLogEntry {
  const AttendanceLogEntry({
    this.employeeName,
    this.status,
    this.timestamp,
  });

  final String? employeeName;
  final String? status;
  final DateTime? timestamp;

  factory AttendanceLogEntry.fromJson(Map<String, dynamic> json) {
    final employee = json['employee'] ?? json['user'] ?? json['employee_name'];
    return AttendanceLogEntry(
      employeeName: _extractName(employee) ?? json['name']?.toString(),
      status: json['status']?.toString() ?? json['type']?.toString(),
      timestamp: _parseDate(
        json['created_at'] ?? json['createdAt'] ?? json['attendance_at'] ?? json['date'],
      ),
    );
  }

  static String? _extractName(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      final name = value['name'] ?? value['full_name'] ?? value['email'];
      return name?.toString();
    }
    return value.toString();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    final parsed = DateTime.tryParse(value.toString());
    return parsed?.toLocal();
  }
}

class _GenericPage {
  _GenericPage({required this.items, required this.total});

  final List<Map<String, dynamic>> items;
  final int total;

  factory _GenericPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final items = data is List
        ? data
            .whereType<Map>()
            .map((item) => item.map((key, value) => MapEntry('$key', value)))
            .toList()
        : const <Map<String, dynamic>>[];

    final meta = json['meta'];
    final total = meta is Map
        ? int.tryParse('${meta['total'] ?? 0}') ?? 0
        : int.tryParse('${json['total'] ?? 0}') ?? 0;

    return _GenericPage(items: items, total: total);
  }
}
