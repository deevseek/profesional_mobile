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
    final maxWidth = switch (format) {
      ReceiptFormat.standard => 760.0,
      ReceiptFormat.thermal80 => 360.0,
      ReceiptFormat.thermal58 => 300.0,
    };
    final padding = switch (format) {
      ReceiptFormat.standard => 24.0,
      ReceiptFormat.thermal80 => 12.0,
      ReceiptFormat.thermal58 => 10.0,
    };

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isThermal ? 8 : 16),
            side: const BorderSide(color: Color(0xFFE4E7EC)),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: isThermal ? (format == ReceiptFormat.thermal58 ? 11 : 12) : 14),
              child: isThermal ? _ThermalReceipt(payload: payload) : _A4Receipt(payload: payload),
            ),
          ),
        ),
      ),
    );
  }
}

class _A4Receipt extends StatelessWidget {
  const _A4Receipt({required this.payload});

  final ReceiptPayloadModel payload;

  @override
  Widget build(BuildContext context) {
    final transaction = payload.transaction;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _StoreHeader(store: payload.store, centered: false, logoSize: 64)),
            const SizedBox(width: 24),
            Expanded(child: _InvoicePanel(payload: payload, alignRight: true)),
          ],
        ),
        const Divider(height: 32),
        _ItemTable(transaction: transaction, isThermal: false),
        const Divider(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _WarrantySection(payload: payload)),
            const SizedBox(width: 24),
            Expanded(child: _SummarySection(transaction: transaction)),
          ],
        ),
        const SizedBox(height: 12),
        _MoneyRow(label: 'Bayar', value: transaction.paidAmount),
        _MoneyRow(label: 'Kembali', value: transaction.changeAmount, strong: true),
        const SizedBox(height: 16),
        const _TermsSection(),
        const SizedBox(height: 28),
        _SignatureSection(store: payload.store),
        const SizedBox(height: 16),
        _Footer(store: payload.store),
      ],
    );
  }
}

class _ThermalReceipt extends StatelessWidget {
  const _ThermalReceipt({required this.payload});

  final ReceiptPayloadModel payload;

  @override
  Widget build(BuildContext context) {
    final transaction = payload.transaction;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StoreHeader(store: payload.store, centered: true, logoSize: 42),
        const Divider(height: 24),
        _InvoicePanel(payload: payload, centeredTitle: true),
        const Divider(height: 24),
        _ItemTable(transaction: transaction, isThermal: true),
        const Divider(height: 24),
        _SummarySection(transaction: transaction, includePaymentRows: true),
        const SizedBox(height: 12),
        _WarrantySection(payload: payload),
        const SizedBox(height: 12),
        const _TermsSection(),
        const SizedBox(height: 16),
        _Footer(store: payload.store),
      ],
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.store, required this.centered, required this.logoSize});

  final ReceiptStoreModel store;
  final bool centered;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final logo = store.effectiveLogoUrl;
    final alignment = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.left;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (logo.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              logo,
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.store_rounded, size: logoSize - 6),
            ),
          )
        else
          Icon(Icons.store_rounded, size: logoSize - 6),
        const SizedBox(height: 6),
        Text(
          _storeName(store).toUpperCase(),
          textAlign: textAlign,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: centered ? 16 : 20),
        ),
        Text(_safe(store.address), textAlign: textAlign),
        Text('WA/Telp: ${_safe(store.phone)}', textAlign: textAlign),
        if (store.hours.trim().isNotEmpty) Text('Jam: ${store.hours.trim()}', textAlign: textAlign),
        ...store.bankAccountNumbers.map((account) => Text('Rekening: $account', textAlign: textAlign)),
        if (store.npwpNumber.trim().isNotEmpty) Text('NPWP: ${store.npwpNumber.trim()}', textAlign: textAlign),
      ],
    );
  }
}

class _InvoicePanel extends StatelessWidget {
  const _InvoicePanel({required this.payload, this.alignRight = false, this.centeredTitle = false});

  final ReceiptPayloadModel payload;
  final bool alignRight;
  final bool centeredTitle;

  @override
  Widget build(BuildContext context) {
    final transaction = payload.transaction;
    final customer = transaction.customer?.name ?? transaction.customerName;
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          'INVOICE',
          textAlign: centeredTitle ? TextAlign.center : (alignRight ? TextAlign.right : TextAlign.left),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        _InfoRow(label: 'No', value: transaction.invoiceNumber.isEmpty ? transaction.id : transaction.invoiceNumber, alignRight: alignRight),
        _InfoRow(label: 'Tgl', value: receiptDate(transaction.createdAt), alignRight: alignRight),
        _InfoRow(label: 'Cust', value: customer.trim().isEmpty ? '-' : customer, alignRight: alignRight),
        _InfoRow(label: 'Metode', value: payload.paymentMethodLabel, alignRight: alignRight),
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
  const _WarrantySection({required this.payload});

  final ReceiptPayloadModel payload;

  @override
  Widget build(BuildContext context) {
    final lines = payload.warrantyTermLines.isNotEmpty ? payload.warrantyTermLines : _fallbackWarrantyLines(payload.transaction);
    if (lines.isEmpty) return const Text('GARANSI: -', style: TextStyle(fontWeight: FontWeight.w900));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('GARANSI', style: TextStyle(fontWeight: FontWeight.w900)),
        ...lines.map((line) => Text(line)),
      ],
    );
  }

  static List<String> _fallbackWarrantyLines(TransactionModel transaction) {
    final warrantyItems = transaction.items.where((item) => (item.product?.warrantyDays ?? 0) > 0).toList(growable: false);
    return warrantyItems.map((item) {
      final days = item.product?.warrantyDays ?? 0;
      final until = transaction.createdAt.add(Duration(days: days));
      return 'GARANSI ${item.name.toUpperCase()}: $days HARI, S/D ${receiptDateOnly(until)}';
    }).toList(growable: false);
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.transaction, this.includePaymentRows = false});

  final TransactionModel transaction;
  final bool includePaymentRows;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _MoneyRow(label: 'Subtotal', value: transaction.subtotal),
          if (transaction.discount > 0) _MoneyRow(label: 'Diskon', value: -transaction.discount),
          if (transaction.taxAmount > 0) _MoneyRow(label: 'PPN / Pajak', value: transaction.taxAmount),
          _MoneyRow(label: 'Total', value: transaction.total, strong: true),
          if (includePaymentRows) ...[
            _MoneyRow(label: 'Bayar', value: transaction.paidAmount),
            _MoneyRow(label: 'Kembali', value: transaction.changeAmount),
          ],
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

  final ReceiptStoreModel store;

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

class _Footer extends StatelessWidget {
  const _Footer({required this.store});

  final ReceiptStoreModel store;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Text('Terima kasih atas kepercayaan Anda.', textAlign: TextAlign.center),
          Text(_storeName(store).toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.alignRight = false});

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            SizedBox(width: 76, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700), textAlign: alignRight ? TextAlign.right : TextAlign.left)),
            const Text(': '),
            Flexible(child: Text(value.trim().isEmpty ? '-' : value.trim(), textAlign: alignRight ? TextAlign.right : TextAlign.left)),
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

String _safe(String value) => value.trim().isEmpty ? '-' : value.trim();
String _storeName(ReceiptStoreModel store) => store.name.trim().isEmpty ? 'PROFESIONAL SERVIS' : store.name.trim();
