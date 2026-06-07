import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:profesionalservis_mobile/features/finance/presentation/providers/finance_provider.dart';

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(financeListProvider(null));
    final money = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(financeListProvider(null)),
      child: async.when(
        loading: () => ListView(padding: const EdgeInsets.all(24), children: const [Center(child: CircularProgressIndicator())]),
        error: (error, _) => ListView(padding: const EdgeInsets.all(24), children: [Text('Keuangan gagal dimuat', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(error.toString()), const SizedBox(height: 12), FilledButton.icon(onPressed: () => ref.invalidate(financeListProvider(null)), icon: const Icon(Icons.refresh), label: const Text('Coba lagi'))]),
        data: (data) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Keuangan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _FinanceTile(label: 'Total Income', value: money.format(data.summary.totalIncome), icon: Icons.trending_up),
                _FinanceTile(label: 'Laba Kotor', value: money.format(data.summary.grossProfit), icon: Icons.show_chart),
                _FinanceTile(label: 'Laba Bersih', value: money.format(data.summary.netProfit), icon: Icons.account_balance_wallet),
                _FinanceTile(label: 'Kas Toko', value: money.format(data.summary.cashAccountBalance), icon: Icons.payments),
                _FinanceTile(label: 'Asset Persediaan', value: money.format(data.summary.inventoryAssetValue), icon: Icons.inventory_2),
              ],
            ),
            const SizedBox(height: 18),
            if (data.items.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('Belum ada data finance.'))),
            ...data.items.map((item) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(item.type == 'expense' ? Icons.arrow_downward : Icons.arrow_upward)),
                    title: Text(item.category, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text([item.note, item.recordedAt?.toIso8601String().split('T').first ?? ''].where((e) => e.isNotEmpty).join(' · ')),
                    trailing: Text(money.format(item.nominal)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _FinanceTile extends StatelessWidget {
  const _FinanceTile({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 220,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 10), Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))]),
          ),
        ),
      );
}
