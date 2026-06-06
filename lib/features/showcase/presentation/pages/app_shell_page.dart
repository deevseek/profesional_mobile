import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/core/responsive/breakpoints.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/features/showcase/presentation/pages/showcase_pages.dart';
import 'package:profesionalservis_mobile/shared/widgets/app_error_view.dart';
import 'package:profesionalservis_mobile/theme/app_colors.dart';

class AppShellPage extends ConsumerStatefulWidget {
  const AppShellPage({super.key});

  @override
  ConsumerState<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends ConsumerState<AppShellPage> {
  int _index = 0;

  static const _items = <_NavItem>[
    _NavItem('Beranda', Icons.dashboard_outlined, Icons.dashboard_rounded, '/home'),
    _NavItem('Servis', Icons.build_circle_outlined, Icons.build_circle_rounded, '/service'),
    _NavItem('POS / Kasir', Icons.point_of_sale_outlined, Icons.point_of_sale_rounded, '/pos'),
    _NavItem('Inventori', Icons.inventory_2_outlined, Icons.inventory_2_rounded, '/inventory'),
    _NavItem('Pelanggan', Icons.people_alt_outlined, Icons.people_alt_rounded, '/customers'),
    _NavItem('Keuangan', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, '/finance'),
    _NavItem('Lainnya', Icons.more_horiz_rounded, Icons.more_horiz_rounded, '/more'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncIndexFromRoute();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final pages = [
      const DashboardShowcasePage(),
      const ServiceOrdersShowcasePage(),
      const PosShowcasePage(),
      const InventoryShowcasePage(),
      const CustomerShowcasePage(),
      const FinanceShowcasePage(),
      SettingsShowcasePage(onLogout: _logout),
    ];

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(_items[_index].label),
              actions: [IconButton(onPressed: () => _showNotifications(context), icon: const Icon(Icons.notifications_outlined))],
            )
          : null,
      body: SafeArea(
        top: false,
        bottom: !isMobile,
        child: Row(
          children: [
            if (!isMobile) _Sidebar(items: _items, selected: _index, onSelect: _selectIndex, onNotifications: () => _showNotifications(context)),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: AppErrorBoundary(
                  key: ValueKey(_index),
                  child: KeyedSubtree(key: ValueKey('page-$_index'), child: pages[_index]),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      floatingActionButtonLocation: isMobile ? FloatingActionButtonLocation.centerDocked : FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _selectIndex,
              destinations: _items.map((item) => NavigationDestination(icon: Icon(item.icon), selectedIcon: Icon(item.selectedIcon), label: item.label)).toList(),
            )
          : null,
    );
  }


  void _syncIndexFromRoute() {
    final path = GoRouterState.of(context).uri.path;
    final normalizedPath = path == '/dashboard' ? '/home' : path;
    final routeIndex = _items.indexWhere((item) => item.path == normalizedPath);
    if (routeIndex >= 0 && routeIndex != _index) {
      _index = routeIndex;
    }
  }

  void _selectIndex(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }
    setState(() => _index = index);
    final path = _items[index].path;
    if (GoRouterState.of(context).uri.path != path) {
      context.go(path);
    }
  }

  Future<void> _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  void _showQuickActions(BuildContext context) {
    final actions = [
      ('Buat Order Servis', Icons.add_task_rounded, 1),
      ('Penjualan POS', Icons.point_of_sale_rounded, 2),
      ('Tambah Produk', Icons.add_box_rounded, 3),
      ('Tambah Pelanggan', Icons.person_add_alt_rounded, 4),
      ('Catat Pengeluaran', Icons.payments_outlined, 5),
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Action', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              ...actions.map((action) => ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.primaryBlue.withValues(alpha: .12), child: Icon(action.$2, color: AppColors.primaryBlue)),
                    title: Text(action.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                    onTap: () {
                      Navigator.pop(context);
                      _selectIndex(action.$3);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    const notifications = [
      ('Order baru', 'SRV-2406-0018 baru masuk', Icons.add_task_rounded, AppColors.primaryBlue),
      ('Stok menipis', 'Battery Samsung A54 tersisa 2 pcs', Icons.warning_amber_rounded, AppColors.warning),
      ('Pembayaran diterima', 'Invoice POS-2406-091 dibayar QRIS', Icons.check_circle_outline, AppColors.success),
      ('Servis selesai', 'Printer Epson siap diambil', Icons.task_alt_rounded, AppColors.teal),
      ('Piutang jatuh tempo', 'CV Bumi Tekno jatuh tempo hari ini', Icons.event_busy_rounded, AppColors.danger),
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text('Notification Center', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...notifications.map((item) => ListTile(
                  leading: CircleAvatar(backgroundColor: item.$4.withValues(alpha: .12), child: Icon(item.$3, color: item.$4)),
                  title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(item.$2),
                )),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.items, required this.selected, required this.onSelect, required this.onNotifications});
  final List<_NavItem> items;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .35))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 48, height: 48, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primaryNavy, borderRadius: BorderRadius.circular(16)), child: Image.asset('assets/branding/app_icon.png')),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Profesional Servis', style: TextStyle(fontWeight: FontWeight.w900)), Text('Cabang Pusat', style: TextStyle(color: AppColors.slate, fontSize: 12))])),
            IconButton(onPressed: onNotifications, icon: const Icon(Icons.notifications_outlined)),
          ]),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final active = index == selected;
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primaryBlue.withValues(alpha: .12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(children: [
                      Icon(active ? item.selectedIcon : item.icon, color: active ? AppColors.primaryBlue : AppColors.slate),
                      const SizedBox(width: 12),
                      Text(item.label, style: TextStyle(fontWeight: active ? FontWeight.w900 : FontWeight.w700, color: active ? AppColors.primaryBlue : null)),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon, this.path);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}
