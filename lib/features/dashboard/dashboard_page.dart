import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/presentation/auth_controller.dart';
import '../categories/presentation/category_list_page.dart';
import '../customers/presentation/customer_list_page.dart';
import '../employees/presentation/employee_list_page.dart';
import '../finances/presentation/finance_list_page.dart';
import '../pos/presentation/pos_page.dart';
import '../products/presentation/product_list_page.dart';
import '../purchases/presentation/purchase_list_page.dart';
import '../purchase_items/presentation/purchase_item_list_page.dart';
import '../payrolls/presentation/payroll_list_page.dart';
import '../attendances/presentation/attendance_list_page.dart';
import '../attendances/presentation/attendance_log_list_page.dart';
import '../service_logs/presentation/service_log_list_page.dart';
import '../services/presentation/service_list_page.dart';
import '../suppliers/presentation/supplier_list_page.dart';
import '../transactions/presentation/transaction_list_page.dart';
import 'dashboard_controller.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/menu_grid.dart';
import 'widgets/overview_cards.dart';
import 'widgets/recent_activity.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({
    super.key,
    required this.authController,
  });

  final AuthController authController;

  static const _pageBackgroundTop = Color(0xFFF6F8FB);
  static const _pageBackgroundBottom = Color(0xFFECEFF5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(dashboardOverviewProvider);
    final recentActivity = ref.watch(dashboardRecentActivityProvider);

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gunakan menu logout untuk keluar.')),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: _pageBackgroundTop,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_pageBackgroundTop, _pageBackgroundBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  ref.refresh(dashboardSummaryProvider.future),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardHeader(
                      userName: authController.user?.name,
                      onNotificationTap: () {},
                      onLogout: () => authController.logout(),
                    ),

                    const SizedBox(height: 28),

                    OverviewCards(
                      data: overview,
                      onRetry: () => ref.invalidate(dashboardSummaryProvider),
                    ),

                    const SizedBox(height: 28),

                    MenuGrid(sections: _buildMenuSections(context)),

                    const SizedBox(height: 24),

                    Text(
                      'Aktivitas Terbaru',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937), // abu gelap modern
                          ),
                    ),

                    const SizedBox(height: 14),

                    RecentActivity(
                      data: recentActivity,
                      onRetry: () => ref.invalidate(dashboardSummaryProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DashboardMenuSection> _buildMenuSections(BuildContext context) {
    return [
      DashboardMenuSection(
        title: 'MASTER DATA',
        titleStyle: _sectionTitleStyle(),
        items: [
          DashboardMenuItem(
            label: 'Customers',
            icon: Icons.people_alt_outlined,
            onTap: () => _openPage(context, const CustomerListPage()),
          ),
          DashboardMenuItem(
            label: 'Employees',
            icon: Icons.badge_outlined,
            onTap: () => _openPage(context, const EmployeeListPage()),
          ),
          DashboardMenuItem(
            label: 'Suppliers',
            icon: Icons.local_shipping_outlined,
            onTap: () => _openPage(context, const SupplierListPage()),
          ),
          DashboardMenuItem(
            label: 'Categories',
            icon: Icons.category_outlined,
            onTap: () => _openPage(context, const CategoryListPage()),
          ),
          DashboardMenuItem(
            label: 'Products',
            icon: Icons.inventory_2_outlined,
            onTap: () => _openPage(context, const ProductListPage()),
          ),
        ],
      ),
      DashboardMenuSection(
        title: 'OPERATIONAL',
        titleStyle: _sectionTitleStyle(),
        items: [
          DashboardMenuItem(
            label: 'Services',
            icon: Icons.build_circle_outlined,
            onTap: () => _openPage(context, const ServiceListPage()),
          ),
          DashboardMenuItem(
            label: 'Attendance',
            icon: Icons.fingerprint_outlined,
            onTap: () => _openPage(context, const AttendanceListPage()),
          ),
          DashboardMenuItem(
            label: 'Attendance Logs',
            icon: Icons.event_available_outlined,
            onTap: () => _openPage(context, const AttendanceLogListPage()),
          ),
          DashboardMenuItem(
            label: 'POS',
            icon: Icons.point_of_sale_outlined,
            onTap: () => _openPage(context, const PosPage()),
          ),
          DashboardMenuItem(
            label: 'Service Logs',
            icon: Icons.history_toggle_off_outlined,
            onTap: () => _openPage(context, const ServiceLogListPage()),
          ),
        ],
      ),
      DashboardMenuSection(
        title: 'FINANCE',
        titleStyle: _sectionTitleStyle(),
        items: [
          DashboardMenuItem(
            label: 'Purchases',
            icon: Icons.shopping_cart_outlined,
            onTap: () => _openPage(context, const PurchaseListPage()),
          ),
          DashboardMenuItem(
            label: 'Purchase Items',
            icon: Icons.playlist_add_check_circle_outlined,
            onTap: () => _openPage(context, const PurchaseItemListPage()),
          ),
          DashboardMenuItem(
            label: 'Transactions',
            icon: Icons.receipt_long_outlined,
            onTap: () => _openPage(context, const TransactionListPage()),
          ),
          DashboardMenuItem(
            label: 'Transaction Items',
            icon: Icons.format_list_bulleted_outlined,
            onTap: () => _openPage(
              context,
              const ModulePlaceholderPage(title: 'Transaction Items'),
            ),
          ),
          DashboardMenuItem(
            label: 'Finances',
            icon: Icons.account_balance_wallet_outlined,
            onTap: () => _openPage(context, const FinanceListPage()),
          ),
          DashboardMenuItem(
            label: 'Payrolls',
            icon: Icons.payments_outlined,
            onTap: () => _openPage(context, const PayrollListPage()),
          ),
        ],
      ),
      DashboardMenuSection(
        title: 'SYSTEM',
        titleStyle: _sectionTitleStyle(),
        items: [
          DashboardMenuItem(
            label: 'Users',
            icon: Icons.people_outline,
            onTap: () => _openPage(
              context,
              const ModulePlaceholderPage(title: 'Users'),
            ),
          ),
          DashboardMenuItem(
            label: 'Roles',
            icon: Icons.shield_outlined,
            onTap: () => _openPage(
              context,
              const ModulePlaceholderPage(title: 'Roles'),
            ),
          ),
          DashboardMenuItem(
            label: 'Permissions',
            icon: Icons.lock_open_outlined,
            onTap: () => _openPage(
              context,
              const ModulePlaceholderPage(title: 'Permissions'),
            ),
          ),
          DashboardMenuItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            onTap: () => _openPage(
              context,
              const ModulePlaceholderPage(title: 'Settings'),
            ),
          ),
        ],
      ),
    ];
  }

  TextStyle _sectionTitleStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
      color: Color(0xFF64748B), // abu profesional
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class ModulePlaceholderPage extends StatelessWidget {
  const ModulePlaceholderPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardPage._pageBackgroundTop,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0.5,
      ),
      body: Center(
        child: Text(
          'Halaman $title belum tersedia.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
