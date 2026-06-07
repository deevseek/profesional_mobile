import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_format_selector.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_print_service.dart';
import 'package:profesionalservis_mobile/features/settings/data/models/store_settings_model.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';

class ReceiptPdfService {
  const ReceiptPdfService._();

  static Future<Uint8List> build({
    required TransactionModel transaction,
    required StoreSettingsModel store,
    required ReceiptFormat receiptFormat,
  }) async {
    final doc = pw.Document();
    final pageFormat = switch (receiptFormat) {
      ReceiptFormat.standard => PdfPageFormat.a4,
      ReceiptFormat.thermal80 => PdfPageFormat(80 * PdfPageFormat.mm, 420 * PdfPageFormat.mm),
      ReceiptFormat.thermal58 => PdfPageFormat(58 * PdfPageFormat.mm, 420 * PdfPageFormat.mm),
    };
    final isThermal = receiptFormat != ReceiptFormat.standard;
    final margin = isThermal ? 4 * PdfPageFormat.mm : 18 * PdfPageFormat.mm;

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.all(margin),
        build: (context) => [
          _header(store, isThermal),
          pw.SizedBox(height: 10),
          _invoiceInfo(transaction, isThermal),
          pw.Divider(),
          _items(transaction, isThermal),
          pw.Divider(),
          _summary(transaction),
          pw.SizedBox(height: 8),
          _warranty(transaction),
          pw.SizedBox(height: 8),
          _terms(store),
          pw.SizedBox(height: 12),
          pw.Center(child: pw.Text('Terima kasih atas kepercayaan Anda.')),
          pw.Center(
            child: pw.Text(
              _storeName(store).toUpperCase(),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header(StoreSettingsModel store, bool isThermal) {
    final children = <pw.Widget>[
      pw.Container(
        width: isThermal ? 34 : 52,
        height: isThermal ? 34 : 52,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey500)),
        child: pw.Text('LOGO', style: const pw.TextStyle(fontSize: 8)),
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        _storeName(store).toUpperCase(),
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: isThermal ? 11 : 18),
        textAlign: pw.TextAlign.center,
      ),
      pw.Text(_safe(store.address), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: isThermal ? 8 : 10)),
      pw.Text('WA/Telp: ${_safe(store.phone)}', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: isThermal ? 8 : 10)),
      if (store.storeHours.trim().isNotEmpty)
        pw.Text('Jam: ${store.storeHours.trim()}', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: isThermal ? 8 : 10)),
      if (store.bankAccount.trim().isNotEmpty)
        pw.Text('Rekening: ${store.bankAccount.trim()}', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: isThermal ? 8 : 10)),
      if (store.npwp.trim().isNotEmpty)
        pw.Text('NPWP: ${store.npwp.trim()}', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: isThermal ? 8 : 10)),
    ];
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: children);
  }

  static pw.Widget _invoiceInfo(TransactionModel trx, bool isThermal) {
    final method = trx.paymentMethod.replaceAll('-', ' ').toUpperCase();
    final customer = trx.customer?.name ?? trx.customerName;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(child: pw.Text('INVOICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: isThermal ? 11 : 16))),
        _kv('No', trx.invoiceNumber.isEmpty ? trx.id : trx.invoiceNumber),
        _kv('Tgl', receiptDate(trx.createdAt)),
        _kv('Cust', customer.trim().isEmpty ? '-' : customer),
        _kv('Metode', method.trim().isEmpty ? '-' : method),
      ],
    );
  }

  static pw.Widget _items(TransactionModel trx, bool isThermal) {
    if (trx.items.isEmpty) return pw.Text('Tidak ada item.');
    return pw.Column(
      children: trx.items.map((item) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(width: isThermal ? 18 : 42, child: pw.Text('${item.quantity}x')),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.name.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('@ ${_money(item.price)}'),
                  ],
                ),
              ),
              pw.SizedBox(width: isThermal ? 58 : 90, child: pw.Text(_money(item.lineTotal), textAlign: pw.TextAlign.right)),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }

  static pw.Widget _summary(TransactionModel trx) => pw.Column(
        children: [
          _moneyRow('Subtotal', trx.subtotal),
          if (trx.discount > 0) _moneyRow('Diskon', -trx.discount),
          if (trx.taxAmount > 0) _moneyRow('PPN (${trx.taxRate.toStringAsFixed(0)}%)', trx.taxAmount),
          _moneyRow('Total', trx.total, bold: true),
          _moneyRow('Bayar', trx.paidAmount),
          _moneyRow('Kembali', trx.changeAmount),
        ],
      );

  static pw.Widget _warranty(TransactionModel trx) {
    final warrantyItems = trx.items.where((item) => (item.product?.warrantyDays ?? 0) > 0).toList(growable: false);
    if (warrantyItems.isEmpty) return pw.Text('GARANSI: -', style: pw.TextStyle(fontWeight: pw.FontWeight.bold));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('GARANSI', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ...warrantyItems.map((item) {
          final days = item.product?.warrantyDays ?? 0;
          final until = trx.createdAt.add(Duration(days: days));
          return pw.Text('${item.name.toUpperCase()}: $days HARI, S/D ${receiptDateOnly(until)}');
        }),
      ],
    );
  }

  static pw.Widget _terms(StoreSettingsModel store) {
    final terms = store.warrantyTerms.trim();
    if (terms.isNotEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Syarat & Ketentuan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...terms.split('\n').where((line) => line.trim().isNotEmpty).map((line) => pw.Text(line.trim())),
        ],
      );
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Syarat & Ketentuan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('1. Barang yang sudah dibeli tidak dapat dikembalikan.'),
        pw.Text('2. Garansi berlaku sesuai ketentuan produk.'),
        pw.Text('3. Simpan nota ini sebagai bukti transaksi.'),
      ],
    );
  }

  static pw.Widget _kv(String label, String value) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 52, child: pw.Text(label)),
          pw.Text(': '),
          pw.Expanded(child: pw.Text(value)),
        ],
      );

  static pw.Widget _moneyRow(String label, int value, {bool bold = false}) => pw.Row(
        children: [
          pw.Expanded(child: pw.Text(label, style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null)),
          pw.Text(_money(value), style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
        ],
      );

  static String _money(num value) => receiptMoney(value);
  static String _safe(String value) => value.trim().isEmpty ? '-' : value.trim();
  static String _storeName(StoreSettingsModel store) => store.storeName.trim().isEmpty ? 'PROFESIONAL SERVIS' : store.storeName.trim();
}
