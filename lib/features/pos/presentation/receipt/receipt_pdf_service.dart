import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/receipt_payload_model.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_format_selector.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_print_service.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';

class ReceiptPdfService {
  const ReceiptPdfService._();

  static Future<Uint8List> build({
    required ReceiptPayloadModel payload,
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
    final logo = await _loadLogo(payload.store.effectiveLogoUrl);

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.all(margin),
        build: (context) => isThermal ? _thermal(payload, logo) : _a4(payload, logo),
      ),
    );

    return doc.save();
  }

  static List<pw.Widget> _a4(ReceiptPayloadModel payload, pw.ImageProvider? logo) {
    final trx = payload.transaction;
    return [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _header(payload.store, false, logo)),
          pw.SizedBox(width: 24),
          pw.Expanded(child: _invoiceInfo(payload, alignRight: true)),
        ],
      ),
      pw.Divider(height: 28),
      _items(trx, false),
      pw.Divider(height: 28),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _warranty(payload)),
          pw.SizedBox(width: 24),
          pw.Expanded(child: _summary(trx)),
        ],
      ),
      pw.SizedBox(height: 8),
      _moneyRow('Bayar', trx.paidAmount),
      _moneyRow('Kembali', trx.changeAmount, bold: true),
      pw.SizedBox(height: 12),
      _terms(),
      pw.SizedBox(height: 28),
      _signature(payload.store),
      pw.SizedBox(height: 12),
      _footer(payload.store),
    ];
  }

  static List<pw.Widget> _thermal(ReceiptPayloadModel payload, pw.ImageProvider? logo) {
    final trx = payload.transaction;
    return [
      _header(payload.store, true, logo),
      pw.Divider(),
      _invoiceInfo(payload, centeredTitle: true),
      pw.Divider(),
      _items(trx, true),
      pw.Divider(),
      _summary(trx, includePaymentRows: true),
      pw.SizedBox(height: 8),
      _warranty(payload),
      pw.SizedBox(height: 8),
      _terms(),
      pw.SizedBox(height: 12),
      _footer(payload.store),
    ];
  }

  static Future<pw.ImageProvider?> _loadLogo(String url) async {
    final logo = url.trim();
    if (logo.isEmpty) return null;
    try {
      return await networkImage(logo);
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _header(ReceiptStoreModel store, bool centered, pw.ImageProvider? logo) {
    final align = centered ? pw.CrossAxisAlignment.center : pw.CrossAxisAlignment.start;
    final textAlign = centered ? pw.TextAlign.center : pw.TextAlign.left;
    final logoSize = centered ? 34.0 : 54.0;
    return pw.Column(
      crossAxisAlignment: align,
      children: [
        if (logo != null)
          pw.Image(logo, width: logoSize, height: logoSize, fit: pw.BoxFit.contain)
        else
          pw.Container(
            width: logoSize,
            height: logoSize,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey500)),
            child: pw.Text('LOGO', style: const pw.TextStyle(fontSize: 8)),
          ),
        pw.SizedBox(height: 6),
        pw.Text(
          _storeName(store).toUpperCase(),
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: centered ? 11 : 18),
          textAlign: textAlign,
        ),
        pw.Text(_safe(store.address), textAlign: textAlign, style: pw.TextStyle(fontSize: centered ? 8 : 10)),
        pw.Text('WA/Telp: ${_safe(store.phone)}', textAlign: textAlign, style: pw.TextStyle(fontSize: centered ? 8 : 10)),
        if (store.hours.trim().isNotEmpty)
          pw.Text('Jam: ${store.hours.trim()}', textAlign: textAlign, style: pw.TextStyle(fontSize: centered ? 8 : 10)),
        ...store.bankAccountNumbers.map(
          (account) => pw.Text('Rekening: $account', textAlign: textAlign, style: pw.TextStyle(fontSize: centered ? 8 : 10)),
        ),
        if (store.npwpNumber.trim().isNotEmpty)
          pw.Text('NPWP: ${store.npwpNumber.trim()}', textAlign: textAlign, style: pw.TextStyle(fontSize: centered ? 8 : 10)),
      ],
    );
  }

  static pw.Widget _invoiceInfo(ReceiptPayloadModel payload, {bool alignRight = false, bool centeredTitle = false}) {
    final trx = payload.transaction;
    final customer = trx.customer?.name ?? trx.customerName;
    return pw.Column(
      crossAxisAlignment: alignRight ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: centeredTitle ? 11 : 16),
          textAlign: centeredTitle ? pw.TextAlign.center : (alignRight ? pw.TextAlign.right : pw.TextAlign.left),
        ),
        _kv('No', trx.invoiceNumber.isEmpty ? trx.id : trx.invoiceNumber, alignRight: alignRight),
        _kv('Tgl', receiptDate(trx.createdAt), alignRight: alignRight),
        _kv('Cust', customer.trim().isEmpty ? '-' : customer, alignRight: alignRight),
        _kv('Metode', payload.paymentMethodLabel, alignRight: alignRight),
      ],
    );
  }

  static pw.Widget _items(TransactionModel trx, bool isThermal) {
    if (trx.items.isEmpty) return pw.Text('Tidak ada item.');
    return pw.Column(
      children: [
        if (!isThermal)
          pw.Row(
            children: [
              pw.Expanded(flex: 5, child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Expanded(flex: 2, child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Expanded(flex: 3, child: pw.Text('Harga', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Expanded(flex: 3, child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            ],
          ),
        ...trx.items.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: isThermal ? _thermalItem(item) : _a4Item(item),
            )),
      ],
    );
  }

  static pw.Widget _thermalItem(TransactionItemModel item) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 18, child: pw.Text('${item.quantity}x')),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.name.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('@ ${_money(item.price)}'),
              ],
            ),
          ),
          pw.SizedBox(width: 58, child: pw.Text(_money(item.lineTotal), textAlign: pw.TextAlign.right)),
        ],
      );

  static pw.Widget _a4Item(TransactionItemModel item) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(flex: 5, child: pw.Text(item.name.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(flex: 2, child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center)),
          pw.Expanded(flex: 3, child: pw.Text(_money(item.price), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 3, child: pw.Text(_money(item.lineTotal), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        ],
      );

  static pw.Widget _summary(TransactionModel trx, {bool includePaymentRows = false}) => pw.Column(
        children: [
          _moneyRow('Subtotal', trx.subtotal),
          if (trx.discount > 0) _moneyRow('Diskon', -trx.discount),
          if (trx.taxAmount > 0) _moneyRow('PPN (${trx.taxRate.toStringAsFixed(0)}%)', trx.taxAmount),
          _moneyRow('Total', trx.total, bold: true),
          if (includePaymentRows) ...[
            _moneyRow('Bayar', trx.paidAmount),
            _moneyRow('Kembali', trx.changeAmount),
          ],
        ],
      );

  static pw.Widget _warranty(ReceiptPayloadModel payload) {
    final lines = payload.warrantyTermLines.isNotEmpty ? payload.warrantyTermLines : _fallbackWarrantyLines(payload.transaction);
    if (lines.isEmpty) return pw.Text('GARANSI: -', style: pw.TextStyle(fontWeight: pw.FontWeight.bold));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('GARANSI', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ...lines.map((line) => pw.Text(line)),
      ],
    );
  }

  static List<String> _fallbackWarrantyLines(TransactionModel trx) {
    final warrantyItems = trx.items.where((item) => (item.product?.warrantyDays ?? 0) > 0).toList(growable: false);
    return warrantyItems.map((item) {
      final days = item.product?.warrantyDays ?? 0;
      final until = trx.createdAt.add(Duration(days: days));
      return 'GARANSI ${item.name.toUpperCase()}: $days HARI, S/D ${receiptDateOnly(until)}';
    }).toList(growable: false);
  }

  static pw.Widget _terms() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Syarat & Ketentuan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('1. Barang yang sudah dibeli tidak dapat dikembalikan.'),
          pw.Text('2. Garansi berlaku sesuai ketentuan produk.'),
          pw.Text('3. Simpan nota ini sebagai bukti transaksi.'),
        ],
      );

  static pw.Widget _signature(ReceiptStoreModel store) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.SizedBox(
            width: 180,
            child: pw.Column(
              children: [
                pw.Text('Hormat Kami,'),
                pw.SizedBox(height: 56),
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.Text(_storeName(store), textAlign: pw.TextAlign.center),
              ],
            ),
          ),
        ],
      );

  static pw.Widget _footer(ReceiptStoreModel store) => pw.Column(
        children: [
          pw.Center(child: pw.Text('Terima kasih atas kepercayaan Anda.')),
          pw.Center(child: pw.Text(_storeName(store).toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
        ],
      );

  static pw.Widget _kv(String label, String value, {bool alignRight = false}) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: alignRight ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.start,
        children: [
          pw.SizedBox(width: 52, child: pw.Text(label, textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left)),
          pw.Text(': '),
          pw.Expanded(child: pw.Text(value.trim().isEmpty ? '-' : value.trim(), textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left)),
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
  static String _storeName(ReceiptStoreModel store) => store.name.trim().isEmpty ? 'PROFESIONAL SERVIS' : store.name.trim();
}
