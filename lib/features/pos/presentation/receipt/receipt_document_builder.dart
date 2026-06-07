import 'package:flutter/material.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/receipt_payload_model.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_format_selector.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_print_service.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';

class ReceiptDocumentBuilder extends StatelessWidget {
  const ReceiptDocumentBuilder({super.key, required this.payload, required this.format});

  final ReceiptPayloadModel payload;
  final ReceiptFormat format;

  bool get isThermal => format != ReceiptFormat.standard;

  @override
  Widget build(BuildContext context) {
    final transaction = payload.transaction;
    final store = payload.store;
    final textTheme = Theme.of(context).textTheme;
    final customer = transaction.customer?.name ?? transaction.customerName;
    final horizontalPadding = switch (format) {
      ReceiptFormat.standard => 24.0,
      ReceiptFormat.thermal80 => 12.0,
      ReceiptFormat.thermal58 => 10.0,
    };

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isThermal ? (format == ReceiptFormat.thermal58 ? 300 : 360) : 720),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isThermal ? 8 : 16),
            side: const BorderSide(color: Color(0xFFE4E7EC)),
          ),
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: isThermal ? (format == ReceiptFormat.thermal58 ? 11 : 12) : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StoreHeader(store: store, isThermal: isThermal),
                  const Divider(height: 24),
                  Text('INVOICE', textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  _InfoRow(label: 'No', value: transaction.invoiceNumber.isEmpty ? transaction.id : transaction.invoiceNumber),
                  _InfoRow(label: 'Tgl', value: receiptDate(transaction.createdAt)),
                  _InfoRow(label: 'Cust', value: customer.trim().isEmpty ? '-' : customer),
                  _InfoRow(label: 'Metode', value: _paymentMethod(transaction)),
                  const Divider(height: 24),
                  _ItemTable(transaction: transaction, isThermal: isThermal),
                  const Divider(height: 24),
                  _WarrantySection(transaction: transaction),
                  const SizedBox(height: 12),
                  _SummarySection(transaction: transaction),
                  const SizedBox(height: 12),
                  const _TermsSection(),
                  if (!isThermal) ...[
                    const SizedBox(height: 28),
                    _SignatureSection(store: store),
                  ],
                  const SizedBox(height: 16),
                  const Text('Terima kasih atas kepercayaan Anda.', textAlign: TextAlign.center),
                  Text(_storeName(store).toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.store, required this.isThermal});

  final StoreReceiptModel store;
  final bool isThermal;

  @override
  Widget build(BuildContext context) {
    final logo = store.logo.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (logo.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              logo,
              width: isThermal ? 42 : 58,
              height: isThermal ? 42 : 58,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.store_rounded, size: isThermal ? 36 : 42),
            ),
          )
        else
          Icon(Icons.store_rounded, size: isThermal ? 36 : 42),
        const SizedBox(height: 6),
        Text(
          _storeName(store).toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: isThermal ? 16 : 20),
        ),
        Text(_safe(store.address), textAlign: TextAlign.center),
        Text('WA/Telp: ${_safe(store.phone)}', textAlign: TextAlign.center),
        if (store.hours.trim().isNotEmpty) Text('Jam: ${store.hours.trim()}', textAlign: TextAlign.center),
        ...store.bankAccountNumbers.map((account) => Text('Rekening: $account', textAlign: TextAlign.center)),
        if (store.npwpNumber.trim().isNotEmpty) Text('NPWP: ${store.npwpNumber.trim()}', textAlign: TextAlign.center),
      ],
    );
  }
}

class _ItemTable extends StatelessWidget {
  const _ItemTable({required this.transaction, required this.isThermal});

  final TransactionModel transaction;
  final bool isThermal;

  @override
  Widget build(BuildContext context) {
    if (transaction.items.isEmpty) return const Text('Tidak ada item.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isThermal)
          const Row(
            children: [
              Expanded(flex: 5, child: Text('Item', style: TextStyle(fontWeight: FontWeight.w900))),
              Expanded(flex: 2, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900))),
              Expanded(flex: 3, child: Text('Harga', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w900))),
              Expanded(flex: 3, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w900))),
            ],
          ),
        ...transaction.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: isThermal ? _thermalItem(item) : _a4Item(item),
            )),
      ],
    );
  }

  Widget _thermalItem(TransactionItemModel item) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 32, child: Text('${item.quantity}x')),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('@ ${receiptMoney(item.price)}'),
              ],
            ),
          ),
          Text(receiptMoney(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      );

  Widget _a4Item(TransactionItemModel item) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: Text(item.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800))),
          Expanded(flex: 2, child: Text('${item.quantity}', textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text(receiptMoney(item.price), textAlign: TextAlign.right)),
          Expanded(flex: 3, child: Text(receiptMoney(item.lineTotal), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      );
}

class _WarrantySection extends StatelessWidget {
  const _WarrantySection({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final warrantyItems = transaction.items.where((item) => (item.product?.warrantyDays ?? 0) > 0).toList(growable: false);
    if (warrantyItems.isEmpty) return const Text('GARANSI: -', style: TextStyle(fontWeight: FontWeight.w900));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('GARANSI', style: TextStyle(fontWeight: FontWeight.w900)),
        ...warrantyItems.map((item) {
          final days = item.product?.warrantyDays ?? 0;
          final until = transaction.createdAt.add(Duration(days: days));
          return Text('GARANSI ${item.name.toUpperCase()}: $days HARI, S/D ${receiptDateOnly(until)}');
        }),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _MoneyRow(label: 'Subtotal', value: transaction.subtotal),
          if (transaction.discount > 0) _MoneyRow(label: 'Diskon', value: -transaction.discount),
          if (transaction.taxAmount > 0) _MoneyRow(label: 'PPN / Pajak', value: transaction.taxAmount),
          _MoneyRow(label: 'Total', value: transaction.total, strong: true),
          _MoneyRow(label: 'Bayar', value: transaction.paidAmount),
          _MoneyRow(label: 'Kembali', value: transaction.changeAmount),
        ],
      );
}

class _TermsSection extends StatelessWidget {
  const _TermsSection();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Syarat & Ketentuan', style: TextStyle(fontWeight: FontWeight.w900)),
          Text('1. Barang yang sudah dibeli tidak dapat dikembalikan.'),
          Text('2. Garansi berlaku sesuai ketentuan produk.'),
          Text('3. Simpan nota ini sebagai bukti transaksi.'),
        ],
      );
}

class _SignatureSection extends StatelessWidget {
  const _SignatureSection({required this.store});

  final StoreReceiptModel store;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 180,
            child: Column(
              children: [
                const Text('Hormat Kami,'),
                const SizedBox(height: 56),
                Container(height: 1, color: const Color(0xFFD0D5DD)),
                Text(_storeName(store), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 76, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            const Text(': '),
            Expanded(child: Text(value.trim().isEmpty ? '-' : value.trim())),
          ],
        ),
      );
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.label, required this.value, this.strong = false});

  final String label;
  final int value;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(label, style: strong ? const TextStyle(fontWeight: FontWeight.w900) : null)),
            Text(receiptMoney(value), style: strong ? const TextStyle(fontWeight: FontWeight.w900) : null),
          ],
        ),
      );
}

String _paymentMethod(TransactionModel transaction) {
  final method = transaction.paymentMethod.replaceAll('-', ' ').toUpperCase();
  return method.trim().isEmpty ? '-' : method;
}

String _safe(String value) => value.trim().isEmpty ? '-' : value.trim();
String _storeName(StoreReceiptModel store) => store.name.trim().isEmpty ? 'PROFESIONAL SERVIS' : store.name.trim();
