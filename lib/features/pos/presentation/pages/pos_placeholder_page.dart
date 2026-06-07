import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/features/attendance/presentation/pages/attendance_page.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/features/customer/presentation/pages/customer_page.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/dashboard_summary_model.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/pos_cart_item.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/providers/pos_provider.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/providers/dashboard_provider.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_url_launcher.dart';
import 'package:profesionalservis_mobile/features/product/data/models/product_model.dart';
import 'package:profesionalservis_mobile/features/product/presentation/pages/product_page.dart';
import 'package:profesionalservis_mobile/features/settings/presentation/pages/settings_page.dart';
import 'package:profesionalservis_mobile/features/services/presentation/pages/service_list_screen.dart';
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
    DashboardMenuItem(label: 'Riwayat Transaksi', icon: Icons.receipt_long_rounded),
    DashboardMenuItem(label: 'Service', icon: Icons.build_circle_rounded),
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
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Cetak Struk Terakhir',
            onPressed: () => _reprintLastReceipt(context, ref, emptyMessage: 'Belum ada transaksi terakhir.'),
            icon: const Icon(Icons.receipt_long_rounded),
          ),
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
                    ? const ServiceListScreen(key: ValueKey('service-page'))
                    : _selectedMenuIndex == 6
                    ? const AttendancePage(key: ValueKey('attendance-page'))
                    : _selectedMenuIndex == 7
                    ? const SettingsPage(key: ValueKey('settings-page'))
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

class _PosContent extends ConsumerStatefulWidget {
  const _PosContent({super.key});

  @override
  ConsumerState<_PosContent> createState() => _PosContentState();
}

class _PosContentState extends ConsumerState<_PosContent> {
  int _mobileSectionIndex = 0;

  @override
  Widget build(BuildContext context) {
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
              state.errorMessage ?? 'Gagal memuat data POS.',
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
              'Checkout sukses · Invoice: ${state.checkoutResult?.invoice ?? '-'} · Subtotal: ${_money(state.checkoutResult?.subtotal ?? 0)} · Total: ${_money(state.checkoutResult?.total ?? 0)} · Kembalian: ${_money(state.checkoutResult?.change ?? 0)}',
              style: const TextStyle(color: Color(0xFF027A48), fontWeight: FontWeight.w600),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 980;

                if (isWide) {
                  return Row(
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
                  );
                }

                return Column(
                  children: [
                    SegmentedButton<int>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment<int>(value: 0, label: Text('Produk')),
                        ButtonSegment<int>(value: 1, label: Text('Cart')),
                      ],
                      selected: {_mobileSectionIndex},
                      onSelectionChanged: (selection) {
                        setState(() => _mobileSectionIndex = selection.first);
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: IndexedStack(
                        index: _mobileSectionIndex,
                        children: [
                          _ProductPanel(state: state, notifier: notifier),
                          _CartPanel(state: state, notifier: notifier),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
            child: state.filteredProducts.isEmpty
                ? const _EmptyStatePanel(
                    icon: Icons.inventory_2_outlined,
                    title: 'Belum ada produk',
                    subtitle: 'Tambahkan produk atau sinkronkan data dari server.',
                  )
                : _ProductGrid(
                    products: state.filteredProducts,
                    onTap: notifier.addToCart,
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
          _CartHeader(state: state, notifier: notifier),
          const SizedBox(height: 8),
          Expanded(
            child: state.cartItems.isEmpty
                ? const _EmptyStatePanel(
                    key: ValueKey('empty-cart'),
                    icon: Icons.remove_shopping_cart_rounded,
                    title: 'Keranjang masih kosong',
                    subtitle: 'Pilih produk terlebih dahulu untuk memulai transaksi.',
                  )
                : ListView.separated(
                    itemCount: state.cartItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = state.cartItems[index];
                      return _CartItemTile(item: item, notifier: notifier);
                    },
                  ),
          ),
          const SizedBox(height: 8),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: _CartSummary(state: state, notifier: notifier),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, required this.onTap});

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100
            ? 5
            : width >= 800
                ? 4
                : width >= 520
                    ? 3
                    : 2;
        final childAspectRatio = width >= 800 ? 0.95 : 0.72;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductGridItem(
              product: product,
              onTap: () => onTap(product),
            );
          },
        );
      },
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  const _ProductGridItem({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = product.name.trim().isEmpty ? '-' : product.name;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: 0.04),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2.2,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF0B63F6),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            Text(
              _money(product.price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF0B63F6),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'Stok ${product.stock}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.state, required this.notifier});

  final PosState state;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text('Cart', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
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
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item, required this.notifier});

  final PosCartItem item;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context) {
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
                child: Text(
                  item.product.name.trim().isEmpty ? '-' : item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () => notifier.removeItem(item.product.id),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              IconButton(
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                padding: EdgeInsets.zero,
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
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                padding: EdgeInsets.zero,
                onPressed: () => notifier.updateQuantity(
                  productId: item.product.id,
                  quantity: item.quantity + 1,
                ),
                icon: const Icon(Icons.add_circle_outline),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 90),
                child: Text(
                  _money(item.lineTotal),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => _showNumberEditor(
              context: context,
              title: 'Diskon item (${item.product.name.trim().isEmpty ? '-' : item.product.name})',
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
  }
}

class _CartSummary extends ConsumerWidget {
  const _CartSummary({required this.state, required this.notifier});

  final PosState state;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Pajak %'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  min: 0,
                  max: 15,
                  divisions: 15,
                  value: state.taxPercent.clamp(0, 15).toDouble(),
                  label: '${state.taxPercent.round()}%',
                  onChanged: notifier.setTaxPercent,
                ),
              ),
              Text('${state.taxPercent.round()}%'),
            ],
          ),
          _SummaryRow(label: 'Cabang', value: state.selectedBranch.trim().isEmpty ? 'Cabang Pusat' : state.selectedBranch),
          Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<PosPaymentMethod>(
                showSelectedIcon: false,
                segments: PosPaymentMethod.values
                    .map((method) => ButtonSegment<PosPaymentMethod>(value: method, label: Text(method.label)))
                    .toList(growable: false),
                selected: {state.selectedPaymentMethod},
                onSelectionChanged: (selection) => notifier.setPaymentMethod(selection.first),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _PaidAmountField(),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Pembayaran', value: state.selectedPaymentMethod.label),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reprintLastReceipt(context, ref),
                  icon: const Icon(Icons.print_rounded),
                  label: const Text('Cetak Struk'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.cartItems.isEmpty || state.isSubmittingCheckout
                      ? null
                      : () => _processCheckout(context: context, ref: ref, notifier: notifier),
                  icon: state.isSubmittingCheckout
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payments_rounded),
                  label: const Text('Bayar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


Future<void> _reprintLastReceipt(
  BuildContext context,
  WidgetRef ref, {
  String emptyMessage = 'Selesaikan pembayaran terlebih dahulu.',
}) async {
  final state = ref.read(posProvider);
  final transactionId = state.lastTransactionId ?? int.tryParse(state.lastPaidTransaction?.id ?? '');
  if (transactionId == null || transactionId <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emptyMessage)));
    return;
  }
  await openPosReceiptUrl(context, ref, transactionId);
}

Future<void> _processCheckout({
  required BuildContext context,
  required WidgetRef ref,
  required PosNotifier notifier,
}) async {
  final before = ref.read(posProvider);
  if (before.cartItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keranjang masih kosong.')));
    return;
  }
  if (before.effectivePaidAmount < before.total) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal bayar kurang.')));
    return;
  }

  final success = await notifier.checkout();
  if (!context.mounted) return;
  final after = ref.read(posProvider);
  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(after.errorMessage ?? 'Transaksi gagal.')));
    return;
  }
  final transactionId = after.lastTransactionId ?? int.tryParse(after.lastPaidTransaction?.id ?? '');
  if (transactionId != null && transactionId > 0) {
    await openPosReceiptUrl(context, ref, transactionId);
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



class _PaidAmountField extends ConsumerStatefulWidget {
  const _PaidAmountField();

  @override
  ConsumerState<_PaidAmountField> createState() => _PaidAmountFieldState();
}

class _PaidAmountFieldState extends ConsumerState<_PaidAmountField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final state = ref.read(posProvider);
    _controller = TextEditingController(text: state.paidAmount > 0 ? _formatNumberPlain(state.paidAmount) : '');
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        final amount = ref.read(posProvider).paidAmount;
        final nextText = amount > 0 ? _formatNumberPlain(amount) : '';
        if (_controller.text != nextText) {
          _controller.text = nextText;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<double>(posProvider.select((s) => s.paidAmount), (prev, next) {
      if (_focusNode.hasFocus) return;
      final nextText = next > 0 ? _formatNumberPlain(next) : '';
      if (_controller.text != nextText) {
        _controller.text = nextText;
      }
    });

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Nominal Bayar',
        prefixText: 'Rp ',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        ref.read(posProvider.notifier).setPaidAmount(parseCurrencyInput(value));
      },
    );
  }
}

double parseCurrencyInput(String value) {
  final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return 0;
  return double.tryParse(clean) ?? 0;
}

String _formatNumberPlain(num value) => value.round().toString();

class _EmptyStatePanel extends StatelessWidget {
  const _EmptyStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: const Color(0xFF98A2B3)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF667085)),
          ),
        ],
      ),
    );
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
