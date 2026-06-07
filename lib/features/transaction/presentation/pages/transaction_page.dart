import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_preview_dialog.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';
import 'package:profesionalservis_mobile/features/transaction/presentation/providers/transaction_provider.dart';

class TransactionPage extends ConsumerWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionProvider);
    final notifier = ref.read(transactionProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: RefreshIndicator(
        onRefresh: notifier.loadTransactions,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              'Transaksi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cari invoice dan filter transaksi berdasarkan tanggal.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: notifier.setSearchInvoice,
              decoration: InputDecoration(
                hintText: 'Search invoice...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: state.searchInvoice.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => notifier.setSearchInvoice(''),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            _DateFilterRow(state: state),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: state.errorMessage!),
            ],
            const SizedBox(height: 14),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.transactions.isEmpty)
              const _EmptyState()
            else
              ...state.transactions.map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TransactionCard(transaction: transaction),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DateFilterRow extends ConsumerWidget {
  const _DateFilterRow({required this.state});

  final TransactionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionProvider.notifier);

    Future<void> pickDate({required bool isStart}) async {
      final now = DateTime.now();
      final initial = isStart ? state.startDate ?? now : state.endDate ?? now;
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(now.year - 2),
        lastDate: DateTime(now.year + 2),
      );

      if (picked == null) {
        return;
      }

      await notifier.setDateFilter(
        startDate: isStart ? picked : state.startDate,
        endDate: isStart ? state.endDate : picked,
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => pickDate(isStart: true),
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(
              state.startDate == null ? 'Dari tanggal' : _dateLabel(state.startDate!),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => pickDate(isStart: false),
            icon: const Icon(Icons.event_rounded, size: 18),
            label: Text(
              state.endDate == null ? 'Sampai tanggal' : _dateLabel(state.endDate!),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Reset filter',
          onPressed: notifier.resetFilter,
          icon: const Icon(Icons.filter_alt_off_rounded),
        ),
      ],
    );
  }
}

class _TransactionCard extends ConsumerWidget {
  const _TransactionCard({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> printReceipt() async {
      final transactionId = int.tryParse(transaction.id);
      if (transactionId == null || transactionId <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID transaksi tidak valid.')));
        return;
      }
      await showTransactionReceipt(context, ref, transactionId);
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TransactionDetailPage(
                transactionId: transaction.id,
                fallbackTransaction: transaction,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF175CD3)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.invoice,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _dateTimeLabel(transaction.date),
                      style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    _StatusBadge(status: transaction.status),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _money(transaction.total),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailPage(
                                transactionId: transaction.id,
                                fallbackTransaction: transaction,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text('Detail'),
                      ),
                      FilledButton.icon(
                        onPressed: printReceipt,
                        icon: const Icon(Icons.print_rounded, size: 16),
                        label: const Text('Cetak'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({
    super.key,
    required this.transactionId,
    required this.fallbackTransaction,
  });

  final String transactionId;
  final TransactionModel fallbackTransaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail transaksi'),
        actions: [
          IconButton(
            tooltip: 'Cetak Struk',
            onPressed: () async {
              final parsedId = int.tryParse(transactionId);
              if (parsedId == null || parsedId <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID transaksi tidak valid.')));
                return;
              }
              await showTransactionReceipt(context, ref, parsedId);
            },
            icon: const Icon(Icons.print_rounded),
          ),
        ],
      ),
      body: detailAsync.when(
        data: (transaction) => _DetailBody(transaction: transaction),
        loading: () => _DetailBody(transaction: fallbackTransaction, showLoading: true),
        error: (_, __) => _DetailBody(transaction: fallbackTransaction),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.transaction, this.showLoading = false});

  final TransactionModel transaction;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (showLoading)
          const LinearProgressIndicator(minHeight: 3)
        else
          const SizedBox.shrink(),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.invoice, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 6),
              _StatusBadge(status: transaction.status),
              const SizedBox(height: 10),
              _DetailRow(label: 'Tanggal', value: _dateTimeLabel(transaction.date)),
              _DetailRow(label: 'Payment method', value: transaction.paymentMethod.isEmpty ? '-' : transaction.paymentMethod),
              _DetailRow(label: 'Subtotal', value: _money(transaction.subtotal)),
              _DetailRow(label: 'Total', value: _money(transaction.total), strong: true),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Item list',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        if (transaction.items.isEmpty)
          const Text('Tidak ada item pada transaksi ini.')
        else
          ...transaction.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${item.quantity} x ${_money(item.price)}', style: const TextStyle(color: Color(0xFF667085))),
                      ],
                    ),
                  ),
                  Text(
                    _money(item.lineTotal),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final color = switch (normalized) {
      'paid' || 'completed' || 'success' => const Color(0xFF12B76A),
      'pending' => const Color(0xFFF79009),
      'cancelled' || 'failed' => const Color(0xFFF04438),
      _ => const Color(0xFF475467),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 12),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: strong ? FontWeight.w800 : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFB42318), fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 46, color: Color(0xFF98A2B3)),
          SizedBox(height: 8),
          Text('Belum ada transaksi ditemukan.'),
        ],
      ),
    );
  }
}

String _dateLabel(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String _dateTimeLabel(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} · $hour:$minute';
}

String _money(int value) {
  final raw = value.toString();
  final grouped = raw.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return 'Rp $grouped';
}
