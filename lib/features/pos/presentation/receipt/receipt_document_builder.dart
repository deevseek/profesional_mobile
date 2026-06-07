import 'package:flutter/material.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_print_service.dart';
import 'package:profesionalservis_mobile/features/settings/data/models/store_settings_model.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';

class ReceiptDocumentBuilder extends StatelessWidget {
  const ReceiptDocumentBuilder({super.key, required this.transaction, required this.store, required this.isThermal});

  final TransactionModel transaction;
  final StoreSettingsModel store;
  final bool isThermal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final customer = transaction.customer?.name ?? transaction.customerName;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isThermal ? 360 : 720),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE4E7EC)),
          ),
          child: Padding(
            padding: EdgeInsets.all(isThermal ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.store_rounded, size: 42),
                const SizedBox(height: 6),
                Text(
                  storeNameOrFallback(store).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: isThermal ? 16 : null),
                ),
                Text(storeAddressOrFallback(store), textAlign: TextAlign.center),
                Text('WA/Telp: ${storePhoneOrFallback(store)}', textAlign: TextAlign.center),
                if (store.storeHours.trim().isNotEmpty) Text('Jam: ${store.storeHours}', textAlign: TextAlign.center),
                if (store.bankAccount.trim().isNotEmpty) Text('Rekening: ${store.bankAccount}', textAlign: TextAlign.center),
                if (store.npwp.trim().isNotEmpty) Text('NPWP: ${store.npwp}', textAlign: TextAlign.center),
                const Divider(height: 24),
                Text('INVOICE', textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                _InfoRow(label: 'No', value: transaction.invoiceNumber.isEmpty ? transaction.id : transaction.invoiceNumber),
                _InfoRow(label: 'Tgl', value: receiptDate(transaction.createdAt)),
                _InfoRow(label: 'Cust', value: customer.trim().isEmpty ? '-' : customer),
                _InfoRow(label: 'Metode', value: transaction.paymentMethod.replaceAll('-', ' ').toUpperCase()),
                const Divider(height: 24),
                ...transaction.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 38, child: Text('${item.quantity}x')),
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
                      ),
                    )),
                const Divider(height: 24),
                _MoneyRow(label: 'Subtotal', value: transaction.subtotal),
                if (transaction.discount > 0) _MoneyRow(label: 'Diskon', value: -transaction.discount),
                if (transaction.taxAmount > 0) _MoneyRow(label: 'PPN / Pajak', value: transaction.taxAmount),
                _MoneyRow(label: 'Total', value: transaction.total, strong: true),
                _MoneyRow(label: 'Bayar', value: transaction.paidAmount),
                _MoneyRow(label: 'Kembali', value: transaction.changeAmount),
                const SizedBox(height: 12),
                _WarrantySection(transaction: transaction),
                const SizedBox(height: 12),
                const Text('Syarat & Ketentuan', style: TextStyle(fontWeight: FontWeight.w900)),
                if (store.warrantyTerms.trim().isNotEmpty)
                  ...store.warrantyTerms.split('\n').where((line) => line.trim().isNotEmpty).map((line) => Text(line.trim()))
                else ...const [
                  Text('1. Barang yang sudah dibeli tidak dapat dikembalikan.'),
                  Text('2. Garansi berlaku sesuai ketentuan produk.'),
                  Text('3. Simpan nota ini sebagai bukti transaksi.'),
                ],
                const SizedBox(height: 16),
                const Text('Terima kasih atas kepercayaan Anda.', textAlign: TextAlign.center),
                Text(storeNameOrFallback(store).toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
          return Text('GARANSI ${item.name.toUpperCase()}: $days HARI, S/D ${receiptDate(until).split(' ').first}');
        }),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 72, child: Text(label)), const Text(': '), Expanded(child: Text(value))]);
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.label, required this.value, this.strong = false});
  final String label;
  final int value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Expanded(child: Text(label, style: strong ? const TextStyle(fontWeight: FontWeight.w900) : null)),
          Text(receiptMoney(value), style: strong ? const TextStyle(fontWeight: FontWeight.w900) : null),
        ]),
      );
}
