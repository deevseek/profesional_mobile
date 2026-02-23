import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/dashboard_summary_model.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/providers/dashboard_provider.dart';
import 'package:profesionalservis_mobile/features/product/presentation/pages/product_page.dart';
import 'package:profesionalservis_mobile/shared/widgets/dashboard_widgets.dart';

class PosPlaceholderPage extends ConsumerStatefulWidget {
  const PosPlaceholderPage({super.key});

  @override
  ConsumerState<PosPlaceholderPage> createState() => _PosPlaceholderPageState();
}

class _PosPlaceholderPageState extends ConsumerState<PosPlaceholderPage> {
  int _selectedMenuIndex = 0;

  static const _menuItems = <DashboardMenuItem>[
    DashboardMenuItem(label: 'Dashboard', icon: Icons.dashboard_rounded),
    DashboardMenuItem(label: 'Kasir (POS)', icon: Icons.point_of_sale_rounded),
    DashboardMenuItem(label: 'Produk', icon: Icons.inventory_2_rounded),
    DashboardMenuItem(label: 'Pelanggan', icon: Icons.people_alt_rounded),
    DashboardMenuItem(label: 'Transaksi', icon: Icons.receipt_long_rounded),
    DashboardMenuItem(label: 'Absensi', icon: Icons.fact_check_rounded),
    DashboardMenuItem(label: 'Pengaturan', icon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final dashboardSummary = ref.watch(dashboardSummaryProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moka Style Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedMenuIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedMenuIndex = index);
              },
              destinations: _menuItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(growable: false),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              _SidebarMenu(
                menuItems: _menuItems,
                selectedMenuIndex: _selectedMenuIndex,
                onSelect: (index) => setState(() => _selectedMenuIndex = index),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _selectedMenuIndex == 0
                    ? _DashboardContent(
                        key: const ValueKey('dashboard-content'),
                        userName: authState.user?.name,
                        summaryAsync: dashboardSummary,
                        onRefresh: () => ref.refresh(dashboardSummaryProvider.future),
                      )
                    : _selectedMenuIndex == 2
                    ? const ProductPage(key: ValueKey('product-page'))
                    : _ComingSoonContent(
                        key: ValueKey('menu-$_selectedMenuIndex'),
                        item: _menuItems[_selectedMenuIndex],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  const _SidebarMenu({
    required this.menuItems,
    required this.selectedMenuIndex,
    required this.onSelect,
  });

  final List<DashboardMenuItem> menuItems;
  final int selectedMenuIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final isSelected = index == selectedMenuIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              onTap: () => onSelect(index),
              leading: Icon(
                item.icon,
                size: 24,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFF344054),
              ),
              title: Text(
                item.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFF344054),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemCount: menuItems.length,
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    super.key,
    required this.userName,
    required this.summaryAsync,
    required this.onRefresh,
  });

  final String? userName;
  final AsyncValue<DashboardSummaryModel> summaryAsync;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Halo, ${userName?.isNotEmpty == true ? userName : 'User'} 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ringkasan performa toko hari ini dari endpoint dashboard.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 18),
          summaryAsync.when(
            data: (summary) => _SummarySection(summary: summary),
            error: (error, _) => _ErrorSummarySection(onRefresh: onRefresh),
            loading: () => const _DashboardSummarySkeleton(),
          ),
          const SizedBox(height: 16),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const _QuickActionSection(),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final DashboardSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      DashboardStatCard(
        title: 'Pendapatan Hari Ini',
        value: _currency(summary.todayRevenue),
        icon: Icons.payments_rounded,
        color: const Color(0xFF0BA5EC),
      ),
      DashboardStatCard(
        title: 'Transaksi Hari Ini',
        value: summary.todayTransactions.toString(),
        icon: Icons.shopping_cart_checkout_rounded,
        color: const Color(0xFF12B76A),
      ),
      DashboardStatCard(
        title: 'Total Produk',
        value: summary.totalProducts.toString(),
        icon: Icons.inventory_rounded,
        color: const Color(0xFF7A5AF8),
      ),
      DashboardStatCard(
        title: 'Pelanggan',
        value: summary.totalCustomers.toString(),
        icon: Icons.people_alt_rounded,
        color: const Color(0xFFF79009),
      ),
      DashboardStatCard(
        title: 'Absensi Hadir',
        value: summary.presentEmployees.toString(),
        icon: Icons.badge_rounded,
        color: const Color(0xFFEE46BC),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1000 ? 4 : width >= 700 ? 3 : 2;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: GridView.builder(
            key: ValueKey(crossAxisCount),
            itemCount: cards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (_, index) => cards[index],
          ),
        );
      },
    );
  }

  String _currency(double value) {
    final raw = value.toStringAsFixed(0);
    final grouped = raw.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $grouped';
  }
}

class _QuickActionSection extends StatelessWidget {
  const _QuickActionSection();

  @override
  Widget build(BuildContext context) {
    const actions = [
      DashboardQuickActionCard(
        title: 'Buka Kasir',
        subtitle: 'Mulai transaksi baru',
        icon: Icons.point_of_sale_rounded,
        color: Color(0xFF0BA5EC),
      ),
      DashboardQuickActionCard(
        title: 'Tambah Produk',
        subtitle: 'Input item baru',
        icon: Icons.add_box_rounded,
        color: Color(0xFF12B76A),
      ),
      DashboardQuickActionCard(
        title: 'Data Pelanggan',
        subtitle: 'Kelola member toko',
        icon: Icons.person_add_alt_1_rounded,
        color: Color(0xFFF79009),
      ),
      DashboardQuickActionCard(
        title: 'Lihat Absensi',
        subtitle: 'Monitoring staf hari ini',
        icon: Icons.schedule_rounded,
        color: Color(0xFF7A5AF8),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1000 ? 4 : width >= 700 ? 3 : 2;

        return GridView.builder(
          itemCount: actions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (_, index) => actions[index],
        );
      },
    );
  }
}

class _DashboardSummarySkeleton extends StatelessWidget {
  const _DashboardSummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (row) => Padding(
          padding: EdgeInsets.only(bottom: row == 1 ? 0 : 12),
          child: Row(
            children: List.generate(
              2,
              (column) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: column == 1 ? 0 : 12),
                  child: const DashboardSkeletonBox(height: 130),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorSummarySection extends StatelessWidget {
  const _ErrorSummarySection({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFFD92D20)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Gagal memuat summary dashboard. Tarik ke bawah untuk refresh.'),
            ),
            TextButton(
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonContent extends StatelessWidget {
  const _ComingSoonContent({
    super.key,
    required this.item,
  });

  final DashboardMenuItem item;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 62, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                item.label,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Modul sedang disiapkan. Gunakan menu Dashboard untuk data utama.'),
            ],
          ),
        ),
      ),
    );
  }
}
