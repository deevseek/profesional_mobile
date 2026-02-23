import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/features/attendance/presentation/pages/attendance_page.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/features/customer/presentation/pages/customer_page.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/dashboard_summary_model.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/providers/pos_provider.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/providers/dashboard_provider.dart';
import 'package:profesionalservis_mobile/features/product/presentation/pages/product_page.dart';
import 'package:profesionalservis_mobile/features/transaction/presentation/pages/transaction_page.dart';
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
                    : _selectedMenuIndex == 1
                    ? const _PosContent(key: ValueKey('pos-content'))
                    : _selectedMenuIndex == 2
                    ? const ProductPage(key: ValueKey('product-page'))
                    : _selectedMenuIndex == 3
                    ? const CustomerPage(key: ValueKey('customer-page'))
                    : _selectedMenuIndex == 4
                    ? const TransactionPage(key: ValueKey('transaction-page'))
                    : _selectedMenuIndex == 5
                    ? const AttendancePage(key: ValueKey('attendance-page'))
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

class _PosContent extends ConsumerWidget {
  const _PosContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posProvider);
    final notifier = ref.read(posProvider.notifier);

    return Column(
      children: [
        if (state.errorMessage != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECDCA)),
            ),
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: Color(0xFFB42318), fontWeight: FontWeight.w600),
            ),
          ),
        if (state.checkoutResult != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA6F4C5)),
            ),
            child: Text(
              'Checkout sukses · Invoice: ${state.checkoutResult!.invoice} · Subtotal: ${_money(state.checkoutResult!.subtotal)} · Total: ${_money(state.checkoutResult!.total)} · Kembalian: ${_money(state.checkoutResult!.change)}',
              style: const TextStyle(color: Color(0xFF027A48), fontWeight: FontWeight.w600),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _ProductPanel(state: state, notifier: notifier),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _CartPanel(state: state, notifier: notifier),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductPanel extends StatelessWidget {
  const _ProductPanel({required this.state, required this.notifier});

  final PosState state;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kasir (POS)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk cepat...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: state.isLoadingProducts
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onChanged: notifier.setSearch,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              itemCount: state.filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.32,
              ),
              itemBuilder: (context, index) {
                final product = state.filteredProducts[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => notifier.addToCart(product),
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(_money(product.price), style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          product.category.isEmpty ? 'Umum' : product.category,
                          style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
                        ),
                      ],
                    ),
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

class _CartPanel extends StatelessWidget {
  const _CartPanel({required this.state, required this.notifier});

  final PosState state;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Cart', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              PopupMenuButton<String>(
                onSelected: (holdId) => notifier.resumeCart(holdId),
                itemBuilder: (context) => state.heldCarts.entries
                    .map(
                      (entry) => PopupMenuItem(
                        value: entry.key,
                        child: Text('${entry.key} (${entry.value.length} item)'),
                      ),
                    )
                    .toList(growable: false),
                child: Chip(
                  label: Text('Hold (${state.heldCarts.length})'),
                  avatar: const Icon(Icons.pause_circle_outline_rounded, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.cartItems.isEmpty
                ? const Center(child: Text('Keranjang kosong. Pilih produk di kiri.'))
                : ListView.separated(
                    itemBuilder: (context, index) {
                      final item = state.cartItems[index];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFF9FAFB),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                                IconButton(
                                  onPressed: () => notifier.removeItem(item.product.id),
                                  icon: const Icon(Icons.delete_outline_rounded),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => notifier.updateQuantity(
                                    productId: item.product.id,
                                    quantity: item.quantity - 1,
                                  ),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                GestureDetector(
                                  onTap: () => _showNumberEditor(
                                    context: context,
                                    title: 'Edit quantity',
                                    initial: item.quantity,
                                    onSave: (value) => notifier.updateQuantity(
                                      productId: item.product.id,
                                      quantity: value,
                                    ),
                                  ),
                                  child: Chip(label: Text('Qty ${item.quantity}')),
                                ),
                                IconButton(
                                  onPressed: () => notifier.updateQuantity(
                                    productId: item.product.id,
                                    quantity: item.quantity + 1,
                                  ),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                                const Spacer(),
                                Text(_money(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => _showNumberEditor(
                                context: context,
                                title: 'Diskon item (${item.product.name})',
                                initial: item.discount,
                                onSave: (value) => notifier.updateDiscount(
                                  productId: item.product.id,
                                  discount: value,
                                ),
                              ),
                              icon: const Icon(Icons.percent_rounded, size: 18),
                              label: Text('Diskon: ${_money(item.discount)}'),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemCount: state.cartItems.length,
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Pajak %'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  min: 0,
                  max: 20,
                  divisions: 20,
                  value: state.taxPercent.toDouble(),
                  label: '${state.taxPercent}%',
                  onChanged: (value) => notifier.setTaxPercent(value.round()),
                ),
              ),
              Text('${state.taxPercent}%'),
            ],
          ),
          _SummaryRow(label: 'Subtotal', value: _money(state.subtotal)),
          _SummaryRow(label: 'Pajak', value: _money(state.taxAmount)),
          _SummaryRow(label: 'Total', value: _money(state.total), isStrong: true),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.cartItems.isEmpty ? null : notifier.holdCart,
                  icon: const Icon(Icons.pause_circle_outline_rounded),
                  label: const Text('Hold cart'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.cartItems.isEmpty
                      ? null
                      : () async {
                          final clear = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clear cart?'),
                              content: const Text('Semua item di cart akan dihapus.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Batal'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          if (clear == true) {
                            notifier.clearCart();
                          }
                        },
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: const Text('Clear cart'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.cartItems.isEmpty || state.isSubmittingCheckout
                  ? null
                  : () => _showCheckoutDialog(context: context, state: state, notifier: notifier),
              icon: state.isSubmittingCheckout
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.receipt_long_rounded),
              label: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showCheckoutDialog({
  required BuildContext context,
  required PosState state,
  required PosNotifier notifier,
}) async {
  final paidController = TextEditingController(text: state.total.toString());

  final shouldCheckout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi checkout'),
      content: TextField(
        controller: paidController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Uang dibayar'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Proses'),
        ),
      ],
    ),
  );

  if (shouldCheckout == true) {
    final paid = int.tryParse(paidController.text.trim()) ?? 0;
    await notifier.checkout(paidAmount: paid);
  }
}

Future<void> _showNumberEditor({
  required BuildContext context,
  required String title,
  required int initial,
  required ValueChanged<int> onSave,
}) async {
  final controller = TextEditingController(text: initial.toString());
  final value = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Nilai'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(int.tryParse(controller.text.trim()) ?? initial),
          child: const Text('Simpan'),
        ),
      ],
    ),
  );

  if (value != null) {
    onSave(value);
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.isStrong = false});

  final String label;
  final String value;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600,
      fontSize: isStrong ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}

String _money(int value) {
  final raw = value.toString();
  final grouped = raw.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return 'Rp $grouped';
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
