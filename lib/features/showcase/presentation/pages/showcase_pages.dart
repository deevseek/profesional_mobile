import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/core/responsive/breakpoints.dart';
import 'package:profesionalservis_mobile/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/providers/dashboard_provider.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/providers/pos_provider.dart';
import 'package:profesionalservis_mobile/features/showcase/data/showcase_models.dart';
import 'package:profesionalservis_mobile/features/showcase/data/showcase_providers.dart';
import 'package:profesionalservis_mobile/shared/widgets/pro_widgets.dart';
import 'package:profesionalservis_mobile/theme/app_colors.dart';
import 'package:profesionalservis_mobile/theme/theme_mode_provider.dart';

class DashboardShowcasePage extends ConsumerWidget {
  const DashboardShowcasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final config = ref.watch(appConfigProvider).valueOrNull;
    final hour = DateTime.now().hour;
    final greeting = hour < 11 ? 'Selamat pagi' : hour < 15 ? 'Selamat siang' : hour < 18 ? 'Selamat sore' : 'Selamat malam';

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(appConfigProvider);
      },
      child: summaryAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            _DashboardHero(greeting: 'Memuat dashboard'),
            SizedBox(height: 18),
            Center(child: CircularProgressIndicator()),
          ],
        ),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _DashboardHero(greeting: greeting),
            const SizedBox(height: 18),
            EmptyStatePanel(
              icon: Icons.error_outline_rounded,
              title: 'Dashboard gagal dimuat',
              message: error.toString(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: () => ref.invalidate(dashboardSummaryProvider), icon: const Icon(Icons.refresh), label: const Text('Coba lagi')),
          ],
        ),
        data: (summary) {
          final kpis = [
            ('Penjualan hari ini', _money(summary.todaySales.round()), Icons.today_rounded, AppColors.success),
            ('Penjualan bulan ini', _money(summary.monthlySales.round()), Icons.calendar_month_rounded, AppColors.primaryBlue),
            ('Transaksi hari ini', summary.transactionsToday.toString(), Icons.receipt_long_rounded, AppColors.warning),
            ('Pelanggan', summary.customersCount.toString(), Icons.people_alt_rounded, AppColors.cyan),
            ('Produk', summary.productsCount.toString(), Icons.inventory_2_rounded, AppColors.primaryNavy),
            ('Servis aktif', summary.activeServicesCount.toString(), Icons.build_circle_rounded, AppColors.danger),
            ('Hutang pembelian', _money(summary.outstandingPurchases.round()), Icons.shopping_bag_outlined, AppColors.slate),
          ];
          final chartValues = summary.financeIncome.isNotEmpty ? summary.financeIncome : summary.financeExpense;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _DashboardHero(greeting: '$greeting, ${config?.storeName ?? 'Profesional Servis'}'),
              const SizedBox(height: 18),
              if (summary.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: EmptyStatePanel(icon: Icons.insights_outlined, title: 'Belum ada data operasional', message: 'Data akan muncul setelah transaksi, servis, pelanggan, dan produk tercatat di API.'),
                ),
              _ResponsiveGrid(
                minTileWidth: 170,
                mobileAspect: 1.2,
                desktopAspect: 1.35,
                children: kpis.map((kpi) => KpiCard(title: kpi.$1, value: kpi.$2, icon: kpi.$3, color: kpi.$4, delta: 'API')).toList(),
              ),
              const SizedBox(height: 22),
              ProCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionHeader(title: 'Income vs Expense 7 hari', subtitle: 'Diambil dari /dashboard/summary'),
                  const SizedBox(height: 18),
                  if (chartValues.isEmpty) const EmptyStatePanel(icon: Icons.bar_chart_outlined, title: 'Grafik kosong', message: 'Belum ada data finance_chart dari API.') else MiniBarChart(values: chartValues.map((v) => v <= 0 ? 1.0 : v).toList()),
                ]),
              ),
              const SizedBox(height: 18),
              _RecentApiList(title: 'Transaksi terbaru', items: summary.recentTransactions),
              const SizedBox(height: 18),
              _RecentApiList(title: 'Servis terbaru', items: summary.recentServices),
            ],
          );
        },
      ),
    );
  }
}

class _RecentApiList extends StatelessWidget {
  const _RecentApiList({required this.title, required this.items});

  final String title;
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return ProCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(title: title, subtitle: 'Data API terbaru'),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const EmptyStatePanel(icon: Icons.inbox_outlined, title: 'Belum ada data', message: 'Data terbaru belum tersedia.'),
        ...items.take(5).map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
              title: Text((item['invoice_number'] ?? item['device'] ?? item['customer_name'] ?? item['name'] ?? '-').toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text((item['status'] ?? item['created_at'] ?? item['updated_at'] ?? '').toString()),
              trailing: Text((item['total'] ?? item['service_fee'] ?? '').toString()),
            )),
      ]),
    );
  }
}

class ServiceOrdersShowcasePage extends ConsumerStatefulWidget {
  const ServiceOrdersShowcasePage({super.key});

  @override
  ConsumerState<ServiceOrdersShowcasePage> createState() => _ServiceOrdersShowcasePageState();
}

class _ServiceOrdersShowcasePageState extends ConsumerState<ServiceOrdersShowcasePage> {
  String _status = 'Semua';

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(showcaseOrdersProvider);
    final filtered = _status == 'Semua' ? orders : orders.where((e) => e.status == _status).toList();
    final detail = filtered.isNotEmpty ? filtered.first : orders.isNotEmpty ? orders.first : const ServiceOrder(number: '-', customer: 'Pengguna', phone: '-', device: '-', issue: '-', dateIn: '-', eta: '-', status: 'Menunggu', color: AppColors.slate);
    final split = !Breakpoints.isMobile(context);

    return Row(
      children: [
        Expanded(
          flex: split ? 5 : 1,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionHeader(title: 'Daftar Order Servis', subtitle: 'Pantau intake, status, dan estimasi pengerjaan', trailing: FilledButton.icon(onPressed: () => _showCreateServiceSheet(context), icon: const Icon(Icons.add_rounded), label: const Text('Buat Tiket'))),
              const SizedBox(height: 14),
              const SearchBox(hint: 'Cari order / nama pelanggan / no HP'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: ['Semua', 'Menunggu', 'Dikerjakan', 'Selesai', 'Dibatalkan'].map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(selected: _status == status, label: Text(status), onSelected: (_) => setState(() => _status = status)),
                  );
                }).toList()),
              ),
              const SizedBox(height: 14),
              ...filtered.map((order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ServiceOrderCard(order: order, onTap: split ? null : () => _showServiceDetail(context, order)),
                  )),
            ],
          ),
        ),
        if (split)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
              child: ServiceDetailPanel(order: detail),
            ),
          ),
      ],
    );
  }
}

class PosShowcasePage extends ConsumerStatefulWidget {
  const PosShowcasePage({super.key});

  @override
  ConsumerState<PosShowcasePage> createState() => _PosShowcasePageState();
}

class _PosShowcasePageState extends ConsumerState<PosShowcasePage> {
  @override
  void initState() {
    super.initState();
    debugPrint('POS page loaded');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posProvider);
    final notifier = ref.read(posProvider.notifier);
    final products = state.filteredProducts;
    final cartItems = state.cartItems;
    debugPrint('products count: ${products.length}');
    debugPrint('cart count: ${cartItems.length}');
    final isTablet = MediaQuery.sizeOf(context).width >= 760;
    final productPanel = ProCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'POS / Kasir', subtitle: 'Search produk cepat atau scan barcode'),
        const SizedBox(height: 12),
        SearchBox(hint: 'Search produk / scan barcode', onChanged: notifier.setSearch, trailingIcon: Icons.qr_code_scanner_rounded),
        const SizedBox(height: 12),
        Expanded(
          child: products.isEmpty
              ? const EmptyStatePanel(icon: Icons.inventory_2_outlined, title: 'Belum ada produk', message: 'Tambahkan produk atau sinkronkan data dari server.')
              : GridView.builder(
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: isTablet ? 220 : 170, childAspectRatio: .9, mainAxisSpacing: 12, crossAxisSpacing: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProCard(
                      onTap: () => notifier.addToCart(product),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(height: 54, decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: .09), borderRadius: BorderRadius.circular(18)), child: const Center(child: Icon(Icons.inventory_2_outlined, color: AppColors.primaryBlue))),
                        const SizedBox(height: 10),
                        Text(product.name.trim().isEmpty ? '-' : product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const Spacer(),
                        Text(_money(product.price), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
                        Text('Stok ${product.stock}', style: const TextStyle(color: AppColors.slate, fontSize: 12)),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
    final cart = CartCheckoutPanel(state: state, notifier: notifier);

    if (!isTablet) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(child: productPanel),
            const SizedBox(height: 12),
            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (_) => SizedBox(
                      height: MediaQuery.sizeOf(context).height * .82,
                      child: Padding(padding: const EdgeInsets.all(16), child: cart),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text('Keranjang (${cartItems.length})'),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [Expanded(flex: 7, child: productPanel), const SizedBox(width: 16), Expanded(flex: 4, child: cart)]),
    );
  }
}

class InventoryShowcasePage extends ConsumerWidget {
  const InventoryShowcasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(showcaseProductsProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 760;
    return ListView(padding: const EdgeInsets.all(20), children: [
      SectionHeader(title: 'Inventori / Produk', subtitle: 'Sparepart, aksesoris, tools, dan stok menipis', trailing: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add_box_outlined), label: const Text('Tambah Produk'))),
      const SizedBox(height: 14),
      const SearchBox(hint: 'Search produk / barcode'),
      const SizedBox(height: 12),
      _FilterRow(items: const ['Semua', 'Sparepart', 'Aksesoris', 'Tools', 'Stok Menipis']),
      const SizedBox(height: 14),
      if (isWide) ProCard(child: Column(children: products.map((p) => _ProductTableRow(product: p)).toList())) else ...products.map((p) => Padding(padding: const EdgeInsets.only(bottom: 12), child: ProductCard(product: p))),
    ]);
  }
}

class CustomerShowcasePage extends ConsumerWidget {
  const CustomerShowcasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(showcaseCustomersProvider);
    final split = !Breakpoints.isMobile(context);
    return Row(children: [
      Expanded(
        flex: 5,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          SectionHeader(title: 'Pelanggan / CRM', subtitle: 'Profil, riwayat servis, transaksi, piutang, dan poin', trailing: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.person_add_outlined), label: const Text('Tambah'))),
          const SizedBox(height: 14),
          const SearchBox(hint: 'Search nama / no HP'),
          const SizedBox(height: 14),
          ...customers.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: CustomerCard(customer: c))),
        ]),
      ),
      if (split) Expanded(flex: 4, child: Padding(padding: const EdgeInsets.fromLTRB(0, 20, 20, 20), child: CustomerDetailPanel(customer: customers.isNotEmpty ? customers.first : const CustomerShowcase(name: 'Pengguna', phone: '-', email: '-', totalService: 0, totalSpend: 'Rp 0', receivable: 'Rp 0')))),
    ]);
  }
}

class FinanceShowcasePage extends StatelessWidget {
  const FinanceShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    const reports = ['Laba Rugi PDF', 'Arus Kas PDF', 'Stok XLSX', 'Penjualan', 'Servis', 'Piutang'];
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SectionHeader(title: 'Keuangan & Laporan', subtitle: 'Arus kas, laba rugi, hutang-piutang, dan export report'),
      const SizedBox(height: 16),
      _ResponsiveGrid(minTileWidth: 160, children: const [
        KpiCard(title: 'Pemasukan', value: 'Rp 86,4 jt', icon: Icons.call_received_rounded, color: AppColors.success, delta: '+14%'),
        KpiCard(title: 'Pengeluaran', value: 'Rp 31,8 jt', icon: Icons.call_made_rounded, color: AppColors.danger, delta: 'Terkendali'),
        KpiCard(title: 'Laba Bersih', value: 'Rp 42,8 jt', icon: Icons.ssid_chart_rounded, color: AppColors.primaryBlue, delta: '+9%'),
        KpiCard(title: 'Hutang-Piutang', value: 'Rp 19,2 jt', icon: Icons.account_balance_outlined, color: AppColors.warning, delta: 'Review'),
      ]),
      const SizedBox(height: 16),
      const ProCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SectionHeader(title: 'Grafik arus kas', subtitle: 'Cashflow 7 hari terakhir'), SizedBox(height: 18), MiniBarChart(values: [4, 6, 5, 8, 7, 10, 9], color: AppColors.teal)])),
      const SizedBox(height: 16),
      _ResponsiveGrid(minTileWidth: 150, mobileAspect: 1.65, desktopAspect: 2.2, children: reports.map((report) => ProCard(child: Row(children: [const Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryBlue), const SizedBox(width: 10), Expanded(child: Text(report, style: const TextStyle(fontWeight: FontWeight.w900)))]))).toList()),
    ]);
  }
}

class SettingsShowcasePage extends ConsumerWidget {
  const SettingsShowcasePage({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final items = const [
      ('Profil pengguna', Icons.person_outline), ('Cabang & gudang', Icons.storefront_outlined), ('Printer', Icons.print_outlined), ('Backup & sinkronisasi', Icons.cloud_sync_outlined), ('Pembayaran', Icons.payments_outlined), ('Pajak & biaya', Icons.receipt_long_outlined), ('Karyawan / role', Icons.badge_outlined),
    ];
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SectionHeader(title: 'Lainnya / Pengaturan', subtitle: 'Konfigurasi aplikasi Profesional Servis'),
      const SizedBox(height: 16),
      ProCard(child: SwitchListTile.adaptive(title: const Text('Tema gelap premium', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: const Text('Preferensi disimpan di secure storage'), value: mode == ThemeMode.dark, onChanged: (value) => ref.read(themeModeProvider.notifier).toggleDarkMode(value))),
      const SizedBox(height: 12),
      ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ProCard(child: Row(children: [Icon(item.$2, color: AppColors.primaryBlue), const SizedBox(width: 12), Expanded(child: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right_rounded)])))),
      OutlinedButton.icon(onPressed: onLogout, icon: const Icon(Icons.logout_rounded), label: const Text('Logout')),
    ]);
  }
}

class ServiceOrderCard extends StatelessWidget {
  const ServiceOrderCard({super.key, required this.order, this.onTap});
  final ServiceOrder order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ProCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(order.number, style: const TextStyle(fontWeight: FontWeight.w900))), StatusChip(label: order.status, color: order.color)]),
        const SizedBox(height: 10),
        Text(order.customer, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('${order.device} · ${order.issue}', style: const TextStyle(color: AppColors.slate)),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 8, children: [
          _MetaPill(icon: Icons.call_outlined, text: order.phone),
          _MetaPill(icon: Icons.login_rounded, text: order.dateIn),
          _MetaPill(icon: Icons.event_available_outlined, text: order.eta),
        ]),
      ]),
    );
  }
}

class ServiceDetailPanel extends StatelessWidget {
  const ServiceDetailPanel({super.key, required this.order});
  final ServiceOrder order;

  @override
  Widget build(BuildContext context) {
    const steps = ['Order diterima', 'Diagnosa', 'Menunggu sparepart', 'Dikerjakan', 'Quality check', 'Selesai'];
    return ProCard(
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(order.number, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))), StatusChip(label: order.status, color: order.color)]),
          const SizedBox(height: 12),
          _InfoBlock(title: 'Info pelanggan', lines: [order.customer, order.phone]),
          _InfoBlock(title: 'Info perangkat', lines: [order.device, order.issue, 'IMEI / Serial opsional']),
          const SectionHeader(title: 'Timeline progress'),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((entry) => _TimelineStep(title: entry.value, active: entry.key <= 3)),
          const SizedBox(height: 14),
          _InfoBlock(title: 'Teknisi & sparepart', lines: const ['Bima · Senior Technician', 'LCD OLED, adhesive seal', 'Catatan: cek ulang waterproof seal sebelum QC']),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: const [
            _ActionButton(icon: Icons.chat_outlined, label: 'Hubungi WhatsApp'),
            _ActionButton(icon: Icons.update_rounded, label: 'Update Progress'),
            _ActionButton(icon: Icons.add_box_outlined, label: 'Tambah Sparepart'),
            _ActionButton(icon: Icons.print_outlined, label: 'Cetak Nota'),
            _ActionButton(icon: Icons.check_circle_outline, label: 'Selesaikan Order'),
          ]),
        ]),
      ),
    );
  }
}

class CartCheckoutPanel extends StatelessWidget {
  const CartCheckoutPanel({super.key, required this.state, required this.notifier});
  final PosState state;
  final PosNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ProCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'Keranjang', subtitle: 'Qty, diskon, pajak, pembayaran'),
        const SizedBox(height: 12),
        Expanded(
          child: state.cartItems.isEmpty
              ? const EmptyStatePanel(icon: Icons.shopping_cart_outlined, title: 'Keranjang masih kosong', message: 'Pilih produk untuk memulai transaksi.')
              : ListView.separated(
                  itemCount: state.cartItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = state.cartItems[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(18)),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.product.name.trim().isEmpty ? '-' : item.product.name, style: const TextStyle(fontWeight: FontWeight.w900)), Text('Qty ${item.quantity} · Diskon ${_money(item.discount)}', style: const TextStyle(color: AppColors.slate))])),
                        IconButton(onPressed: () => notifier.updateQuantity(productId: item.product.id, quantity: item.quantity - 1), icon: const Icon(Icons.remove_circle_outline)),
                        IconButton(onPressed: () => notifier.updateQuantity(productId: item.product.id, quantity: item.quantity + 1), icon: const Icon(Icons.add_circle_outline)),
                        Text(_money(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.w900)),
                      ]),
                    );
                  },
                ),
        ),
        Row(children: [const Text('Pajak'), Expanded(child: Slider(min: 0, max: 20, divisions: 20, value: state.taxPercent.toDouble(), onChanged: (v) => notifier.setTaxPercent(v.round()))), Text('${state.taxPercent}%')]),
        _SummaryLine(label: 'Cabang', value: state.selectedBranch.trim().isEmpty ? 'Cabang Pusat' : state.selectedBranch),
        _SummaryLine(label: 'Pembayaran', value: state.selectedPaymentMethod.trim().isEmpty ? 'Tunai' : state.selectedPaymentMethod),
        _SummaryLine(label: 'Subtotal', value: _money(state.subtotal)),
        _SummaryLine(label: 'Pajak', value: _money(state.taxAmount)),
        _SummaryLine(label: 'Total', value: _money(state.total), strong: true),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: const ['Tunai', 'Transfer', 'QRIS', 'Debit'].map((m) => ChoiceChip(selected: m == 'Tunai', label: Text(m))).toList()),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: OutlinedButton.icon(onPressed: state.cartItems.isEmpty ? null : notifier.holdCart, icon: const Icon(Icons.pause_circle_outline), label: const Text('Hold'))), const SizedBox(width: 8), Expanded(child: FilledButton.icon(onPressed: state.cartItems.isEmpty ? null : () => notifier.checkout(paidAmount: state.total), icon: const Icon(Icons.payments_outlined), label: const Text('Bayar')))]),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.print_outlined), label: const Text('Cetak Struk')),
      ]),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final ProductShowcase product;
  @override
  Widget build(BuildContext context) => ProCard(child: _ProductContent(product: product));
}

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer});
  final CustomerShowcase customer;
  @override
  Widget build(BuildContext context) => ProCard(child: Row(children: [CircleAvatar(backgroundColor: AppColors.primaryBlue.withValues(alpha: .12), child: Text((customer.name.isNotEmpty ? customer.name[0] : '-'), style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w900)), Text('${customer.phone} · ${customer.email}', style: const TextStyle(color: AppColors.slate)), Text('Servis ${customer.totalService} · Belanja ${customer.totalSpend} · Piutang ${customer.receivable}', style: const TextStyle(color: AppColors.slate, fontSize: 12))])), const Icon(Icons.chat_outlined, color: AppColors.teal)]));
}

class CustomerDetailPanel extends StatelessWidget {
  const CustomerDetailPanel({super.key, required this.customer});
  final CustomerShowcase customer;
  @override
  Widget build(BuildContext context) => ProCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [CircleAvatar(radius: 30, backgroundColor: AppColors.primaryBlue, child: Text((customer.name.isNotEmpty ? customer.name[0] : '-'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(customer.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), Text(customer.phone), Text(customer.email)]))]),
        const SizedBox(height: 18),
        _ResponsiveGrid(minTileWidth: 130, mobileAspect: 1.7, desktopAspect: 1.7, children: [
          KpiCard(title: 'Total servis', value: '${customer.totalService}', icon: Icons.build_outlined, color: AppColors.primaryBlue),
          KpiCard(title: 'Total belanja', value: customer.totalSpend, icon: Icons.shopping_bag_outlined, color: AppColors.success),
          KpiCard(title: 'Piutang', value: customer.receivable, icon: Icons.account_balance_wallet_outlined, color: AppColors.warning),
          const KpiCard(title: 'Poin', value: '1.240', icon: Icons.stars_outlined, color: AppColors.teal),
        ]),
        const SizedBox(height: 14),
        const SectionHeader(title: 'Riwayat servis & transaksi'),
        const SizedBox(height: 8),
        const _TimelineStep(title: 'SRV-2406-0018 · iPhone 13 Pro', active: true),
        const _TimelineStep(title: 'POS-2405-0182 · Pembelian aksesoris', active: true),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add_task_rounded), label: const Text('Buat order baru'))), const SizedBox(width: 8), OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat_outlined), label: const Text('WhatsApp'))]),
      ]));
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.greeting});
  final String greeting;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [AppColors.primaryNavy, AppColors.primaryBlue])),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$greeting 👋', style: TextStyle(color: Colors.white.withValues(alpha: .78), fontWeight: FontWeight.w700)), const SizedBox(height: 8), Text('Cabang Pusat', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text('Operasional servis, POS, inventori, dan laporan dalam satu workspace premium.', style: TextStyle(color: Colors.white.withValues(alpha: .78)))])),
          IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
        ]),
      );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});
  final ActivityItem item;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: item.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)), child: Icon(item.icon, color: item.color, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900)), Text(item.subtitle, style: const TextStyle(color: AppColors.slate, fontSize: 12))]))]));
}

class _TechnicianRow extends StatelessWidget {
  const _TechnicianRow({required this.name, required this.role, required this.progress, required this.done});
  final String name, role, done;
  final double progress;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '-')), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w900)), Text(role, style: const TextStyle(color: AppColors.slate)), const SizedBox(height: 6), LinearProgressIndicator(value: progress, borderRadius: BorderRadius.circular(999))])), const SizedBox(width: 10), Text(done, style: const TextStyle(fontWeight: FontWeight.w800))]));
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children, this.minTileWidth = 180, this.mobileAspect = 1.15, this.desktopAspect = 1.35});
  final List<Widget> children;
  final double minTileWidth, mobileAspect, desktopAspect;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final count = (constraints.maxWidth / minTileWidth).floor().clamp(1, 4).toInt();
        return GridView.count(crossAxisCount: count, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: count == 1 ? mobileAspect : desktopAspect, children: children);
      });
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.items});
  final List<String> items;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: items.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(selected: e.key == 0, label: Text(e.value), onSelected: (_) {}))).toList()));
}

class _ProductTableRow extends StatelessWidget {
  const _ProductTableRow({required this.product});
  final ProductShowcase product;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: _ProductContent(product: product));
}

class _ProductContent extends StatelessWidget {
  const _ProductContent({required this.product});
  final ProductShowcase product;
  @override
  Widget build(BuildContext context) {
    final color = product.stock == 0 ? AppColors.danger : product.stock <= 5 ? AppColors.warning : AppColors.success;
    final status = product.stock == 0 ? 'Habis' : product.stock <= 5 ? 'Stok Menipis' : 'Aman';
    return Row(children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)), child: Icon(Icons.inventory_2_outlined, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900)), Text('${product.sku} · ${product.category}', style: const TextStyle(color: AppColors.slate)), Text('Beli ${product.buyPrice} · Jual ${product.sellPrice}', style: const TextStyle(color: AppColors.slate, fontSize: 12))])), StatusChip(label: '$status · ${product.stock}', color: color)]);
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.title, required this.active});
  final String title;
  final bool active;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(active ? Icons.check_circle : Icons.radio_button_unchecked, color: active ? AppColors.success : AppColors.slate), const SizedBox(width: 10), Expanded(child: Text(title, style: TextStyle(fontWeight: active ? FontWeight.w800 : FontWeight.w600)))]));
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.lines});
  final String title;
  final List<String> lines;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 6), ...lines.map((line) => Text(line, style: const TextStyle(color: AppColors.slate)))]));
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: AppColors.slate), const SizedBox(width: 5), Text(text, style: const TextStyle(color: AppColors.slate, fontWeight: FontWeight.w700, fontSize: 12))]));
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(onPressed: () {}, icon: Icon(icon), label: Text(label));
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value, this.strong = false});
  final String label, value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Text(label, style: TextStyle(fontWeight: strong ? FontWeight.w900 : FontWeight.w700)), const Spacer(), Text(value, style: TextStyle(fontWeight: strong ? FontWeight.w900 : FontWeight.w700, fontSize: strong ? 18 : 14))]));
}

void _showCreateServiceSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: const [
              SectionHeader(
                title: 'Buat Tiket / Order Servis',
                subtitle:
                    'Foto opsional, maksimal 10 foto. TODO: hubungkan upload ke endpoint media service.',
              ),
              SizedBox(height: 14),
              _IntakeForm(),
            ],
          );
        },
      );
    },
  );
}

void _showServiceDetail(BuildContext context, ServiceOrder order) {
  showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => SizedBox(height: MediaQuery.sizeOf(context).height * .9, child: Padding(padding: const EdgeInsets.all(16), child: ServiceDetailPanel(order: order))));
}

class _IntakeForm extends StatelessWidget {
  const _IntakeForm();
  @override
  Widget build(BuildContext context) {
    const fields = ['Pelanggan', 'No HP', 'Perangkat', 'Merek', 'Model', 'IMEI / Serial opsional', 'Keluhan utama', 'Kelengkapan barang', 'Estimasi pengerjaan', 'Estimasi biaya'];
    return Column(children: [
      ...fields.map((field) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(maxLines: field.contains('Keluhan') ? 3 : 1, decoration: InputDecoration(labelText: field)))),
      DropdownButtonFormField<String>(value: 'Normal', decoration: const InputDecoration(labelText: 'Prioritas'), items: const ['Rendah', 'Normal', 'Tinggi'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(), onChanged: (_) {}),
      const SizedBox(height: 10),
      OutlinedButton.icon(onPressed: null, icon: Icon(Icons.camera_alt_outlined), label: Text('Tambah foto barang / kerusakan (opsional)')),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: null, icon: Icon(Icons.save_outlined), label: Text('Simpan tiket')),
    ]);
  }
}

String _money(int value) {
  final raw = value.toString();
  final grouped = raw.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return 'Rp $grouped';
}
