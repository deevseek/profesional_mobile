import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/presentation/auth_controller.dart';
import '../categories/presentation/category_list_page.dart';
import '../customers/presentation/customer_list_page.dart';
import '../employees/presentation/employee_list_page.dart';
import '../products/presentation/product_list_page.dart';
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                ref.refresh(dashboardOverviewProvider.future),
                ref.refresh(dashboardRecentActivityProvider.future),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(
                    userName: authController.user?.name,
                    onNotificationTap: () {},
                    onLogout: () => authController.logout(),
                  ),
                  const SizedBox(height: 20),
                  OverviewCards(
                    data: overview,
                    onRetry: () => ref.invalidate(dashboardOverviewProvider),
                  ),
                  const SizedBox(height: 24),
                  MenuGrid(sections: _buildMenuSections(context)),
                  const SizedBox(height: 8),
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  RecentActivity(
                    data: recentActivity,
                    onRetry: () => ref.invalidate(dashboardRecentActivityProvider),
                  ),
                ],
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
        items: [
          DashboardMenuItem(
            label: 'Services',
            icon: Icons.build_circle_outlined,
            onTap: () => _openPage(context, const ServiceListPage()),
          ),
          DashboardMenuItem(
            label: 'Attendance',
            icon: Icons.fingerprint_outlined,
            onTap: () => _openPage(
              context,
              const ModulePlaceholderPage(title: 'Attendance'),
            ),
          ),
          DashboardMenuItem(
            label: 'Attendance Logs',
            icon: Icons.event_available_outlined,
            onTap: () => _openPage(
              context,
              const ModulePlaceholderPage(title: 'Attendance Logs'),
            ),
          ),
          DashboardMenuItem(
            label: 'Cash Sessions',
            icon: Icons.point_of_sale_outlined,
            onTap: () => _openPage(
              context,
              const ModulePlaceholderPage(title: 'Cash Sessions'),
            ),
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
        items: [
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
            onTap: () => _openPage(
              context,
              const ModulePlaceholderPage(title: 'Finances'),
            ),
          ),
          DashboardMenuItem(
            label: 'Payrolls',
            icon: Icons.payments_outlined,
            onTap: () => _openPage(
              context,
              const ModulePlaceholderPage(title: 'Payrolls'),
            ),
          ),
        ],
      ),
      DashboardMenuSection(
        title: 'SYSTEM',
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
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'Halaman $title belum tersedia.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
