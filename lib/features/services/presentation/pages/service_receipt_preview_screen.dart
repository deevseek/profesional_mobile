import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_model.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';

enum ReceiptFormat { standard, thermal80, thermal58 }

class ServiceReceiptPreviewScreen extends StatefulWidget {
  const ServiceReceiptPreviewScreen({
    super.key,
    required this.service,
    this.store = const <String, dynamic>{},
    this.transaction,
  });

  final ServiceModel service;
  final Map<String, dynamic> store;
  final TransactionModel? transaction;

  @override
  State<ServiceReceiptPreviewScreen> createState() => _ServiceReceiptPreviewScreenState();
}

class _ServiceReceiptPreviewScreenState extends State<ServiceReceiptPreviewScreen> {
  ReceiptFormat _selectedFormat = ReceiptFormat.standard;

  bool get isInvoiceMode => widget.transaction != null;
  bool get isReceiptMode => !isInvoiceMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(isInvoiceMode ? 'Invoice Service' : 'Tanda Terima Service')),
      body: ColoredBox(
        color: const Color(0xFF111827),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937),
                border: Border(bottom: BorderSide(color: Color(0xFF374151))),
              ),
              child: Wrap(
                runSpacing: 10,
                spacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _formatChip('📄 A4 Standard', ReceiptFormat.standard),
                      _formatChip('🧾 Thermal 80mm', ReceiptFormat.thermal80),
                      _formatChip('🧾 Thermal 58mm', ReceiptFormat.thermal58),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: _printReceipt,
                    icon: const Icon(Icons.print),
                    label: Text(isInvoiceMode ? 'CETAK INVOICE' : 'CETAK TANDA TERIMA'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: _receiptWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: isThermal ? 14 : 22,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: DefaultTextStyle(
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        fontSize: _selectedFormat == ReceiptFormat.thermal58 ? 11 : 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 8),
                          _line(doubleLine: true),
                          const SizedBox(height: 8),
                          _buildItemsTable(),
                          const SizedBox(height: 8),
                          _line(dashed: true),
                          const SizedBox(height: 8),
                          _buildTotals(),
                          if (isReceiptMode) ...[
                            const SizedBox(height: 12),
                            _line(dashed: true),
                            const SizedBox(height: 10),
                            _buildTrackingQr(),
                          ],
                          const SizedBox(height: 16),
                          if (!isThermal) _buildSignature() else _buildThermalFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formatChip(String label, ReceiptFormat format) {
    final selected = _selectedFormat == format;
    return ChoiceChip(
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      ),
      selected: selected,
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: const Color(0xFF4B5563),
      onSelected: (_) => setState(() => _selectedFormat = format),
    );
  }

  Widget _buildHeader() {
    final title = isInvoiceMode ? 'INVOICE SERVIS' : 'TANDA TERIMA SERVIS';
    final paymentMethod = widget.transaction?.paymentMethod.replaceAll('-', ' ').toUpperCase() ?? '-';
    final invoiceNumber = widget.transaction?.invoice.isNotEmpty == true
        ? widget.transaction!.invoice
        : widget.service.serviceNumber;

    if (isThermal) {
      return Column(
        children: [
          Text(_storeName.toUpperCase(), textAlign: TextAlign.center, style: _titleStyle),
          if (_storeAddress.isNotEmpty) Text(_storeAddress, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('$title #$invoiceNumber', textAlign: TextAlign.center),
          Text('TGL: ${_dateFormat(widget.transaction?.date ?? widget.service.createdAt)}', textAlign: TextAlign.center),
          Text('CUST: ${widget.service.customerName.toUpperCase()}', textAlign: TextAlign.center),
          Text('METODE: $paymentMethod', textAlign: TextAlign.center),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_storeName.toUpperCase(), style: _titleStyle),
              if (_storeAddress.isNotEmpty) Text(_storeAddress),
              Text('METODE: $paymentMethod'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            Text('NO: $invoiceNumber'),
            Text('TGL: ${_dateFormat(widget.transaction?.date ?? widget.service.createdAt)}'),
            Text('CUST: ${widget.service.customerName.toUpperCase()}'),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    final items = widget.transaction?.items ?? const <TransactionItemModel>[];
    final hasItems = items.isNotEmpty;

    if (isReceiptMode) {
      return Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(5.9),
        },
        children: [
          TableRow(
            children: [
              _cell('QTY', header: true),
              _cell('DESKRIPSI', header: true),
            ],
          ),
          ...(hasItems
              ? items.map(
                  (item) => TableRow(
                    children: [
                      _cell('${item.quantity}', center: true),
                      _cell(item.name.isEmpty ? 'JASA SERVICE' : item.name.toUpperCase()),
                    ],
                  ),
                )
              : [
                  TableRow(
                    children: [
                      _cell('1', center: true),
                      _cell('JASA SERVICE\nUNIT: ${widget.service.deviceName.toUpperCase()}'),
                    ],
                  ),
                ]),
        ],
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(3.7),
        2: FlexColumnWidth(2.2),
      },
      children: [
        TableRow(
          children: [
            _cell('QTY', header: true),
            _cell('DESKRIPSI', header: true),
            _cell('TOTAL', header: true, alignRight: true),
          ],
        ),
        ...(hasItems
            ? items.map(
                (item) => TableRow(
                  children: [
                    _cell('${item.quantity}', center: true),
                    _cell(item.name.isEmpty ? 'JASA SERVICE' : item.name.toUpperCase()),
                    _cell(_money(item.lineTotal), alignRight: true),
                  ],
                ),
              )
            : [
                TableRow(
                  children: [
                    _cell('1', center: true),
                    _cell('JASA SERVICE\nUNIT: ${widget.service.deviceName.toUpperCase()}'),
                    _cell(_money(widget.service.finalCost), alignRight: true),
                  ],
                ),
              ]),
      ],
    );
  }

  Widget _buildTotals() {
    if (isReceiptMode) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isThermal)
            Expanded(
              child: Text(
                'DEVICE: ${widget.service.deviceName.toUpperCase()}\nKELUHAN: ${widget.service.complaint.toUpperCase()}',
              ),
            )
          else
            Expanded(
              child: Text(
                'DEVICE: ${widget.service.deviceName.toUpperCase()}\nKELUHAN: ${widget.service.complaint.toUpperCase()}',
              ),
            ),
        ],
      );
    }

    final subtotal = widget.transaction?.subtotal ?? widget.service.finalCost;
    final total = widget.transaction?.total ?? widget.service.finalCost;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isThermal)
          Expanded(
            child: Text('DEVICE: ${widget.service.deviceName.toUpperCase()}\nKELUHAN: ${widget.service.complaint.toUpperCase()}'),
          ),
        Expanded(
          child: Table(
            children: [
              _totalRow('SUBTOTAL:', _money(subtotal)),
              _totalRow('TOTAL:', _money(total), emphasize: true),
              _totalRow('DEPOSIT:', _money(widget.service.estimatedCost)),
              _totalRow('SISA:', _money((total - widget.service.estimatedCost).clamp(0, total))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingQr() {
    final url = _progressTrackingUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'CEK PROGRES PEKERJAAN ONLINE',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Center(
          child: QrImageView(
            data: url,
            version: QrVersions.auto,
            size: isThermal ? 110 : 150,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          url,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  TableRow _totalRow(String label, String value, {bool emphasize = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildSignature() {
    return Row(
      children: [
        Expanded(child: _signBox('HORMAT KAMI', 'ADMIN')),
        const SizedBox(width: 24),
        Expanded(child: _signBox('CUSTOMER', widget.service.customerName.toUpperCase())),
      ],
    );
  }

  Widget _buildThermalFooter() {
    return Column(
      children: [
        _line(dashed: true),
        const SizedBox(height: 8),
        const Text('TERIMA KASIH ATAS KEPERCAYAAN ANDA', textAlign: TextAlign.center),
        const Text('* KLAIM GARANSI WAJIB SERTAKAN NOTA INI *', textAlign: TextAlign.center),
        Text('DICETAK: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', textAlign: TextAlign.center),
      ],
    );
  }

  Widget _signBox(String title, String name) {
    return Column(
      children: [
        Text('$title,', textAlign: TextAlign.center),
        const SizedBox(height: 50),
        Text('($name)', textAlign: TextAlign.center),
      ],
    );
  }

  Widget _cell(
    String text, {
    bool header = false,
    bool alignRight = false,
    bool center = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: header
          ? const BoxDecoration(
              border: Border(
                top: BorderSide(width: 1.5, color: Colors.black),
                bottom: BorderSide(width: 1.5, color: Colors.black),
              ),
            )
          : null,
      child: Text(
        text,
        textAlign: alignRight
            ? TextAlign.right
            : center
                ? TextAlign.center
                : TextAlign.left,
      ),
    );
  }

  Widget _line({bool dashed = false, bool doubleLine = false}) {
    return Container(
      height: doubleLine ? 4 : 1.5,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: dashed ? 1.5 : (doubleLine ? 4 : 1.5),
            style: dashed ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
      ),
    );
  }

  double get _receiptWidth => switch (_selectedFormat) {
        ReceiptFormat.standard => 800,
        ReceiptFormat.thermal80 => 360,
        ReceiptFormat.thermal58 => 300,
      };

  bool get isThermal => _selectedFormat != ReceiptFormat.standard;

  TextStyle get _titleStyle => const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, height: 1.1);

  String get _storeName => (widget.store['name'] ?? '').toString().trim().isEmpty
      ? 'Profesional Servis'
      : (widget.store['name'] ?? '').toString();

  String get _storeAddress => (widget.store['address'] ?? '').toString();

  String get _progressTrackingUrl {
    final directUrl = (widget.store['service_tracking_url'] ?? widget.store['tracking_url'] ?? '').toString().trim();
    if (directUrl.isNotEmpty) {
      return directUrl;
    }

    final baseUrl = (widget.store['service_tracking_base_url'] ?? widget.store['tracking_base_url'] ?? '').toString().trim();
    if (baseUrl.isNotEmpty) {
      final number = Uri.encodeComponent(widget.service.serviceNumber);
      return '$baseUrl/$number';
    }

    final serviceToken = widget.service.serviceNumber.isNotEmpty ? widget.service.serviceNumber : widget.service.id;
    final encoded = Uri.encodeComponent(serviceToken);
    return 'https://service.profesionalservis.com/track/$encoded';
  }

  String _dateFormat(DateTime? date) => DateFormat('dd/MM/yyyy HH:mm').format(date ?? DateTime.now());

  String _money(int amount) {
    final formatted = NumberFormat('#,###', 'id_ID').format(amount).replaceAll(',', '.');
    return 'Rp $formatted';
  }

  Future<void> _printReceipt() async {
    final regularFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final doc = pw.Document();
    final items = widget.transaction?.items ?? const <TransactionItemModel>[];
    final hasItems = items.isNotEmpty;

    final baseTextStyle = pw.TextStyle(
      fontSize: _selectedFormat == ReceiptFormat.thermal58 ? 9 : 10,
      fontWeight: pw.FontWeight.bold,
      lineSpacing: 1.2,
    );
    final titleStyle = pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold);

    pw.Widget pdfLine({bool dashed = false, bool doubleLine = false}) {
      if (dashed) {
        return pw.Row(
          children: List.generate(
            24,
            (_) => pw.Expanded(
              child: pw.Container(
                height: 1.2,
                margin: const pw.EdgeInsets.symmetric(horizontal: 1.2),
                color: PdfColors.black,
              ),
            ),
          ),
        );
      }

      return pw.Container(
        height: doubleLine ? 4 : 1.5,
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(width: doubleLine ? 4 : 1.5, color: PdfColors.black)),
        ),
      );
    }

    pw.Widget cell(
      String text, {
      bool header = false,
      bool alignRight = false,
      bool center = false,
    }) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        decoration: header
            ? pw.BoxDecoration(
                border: const pw.Border(
                  top: pw.BorderSide(width: 1.5, color: PdfColors.black),
                  bottom: pw.BorderSide(width: 1.5, color: PdfColors.black),
                ),
              )
            : null,
        child: pw.Text(
          text,
          textAlign: alignRight
              ? pw.TextAlign.right
              : center
                  ? pw.TextAlign.center
                  : pw.TextAlign.left,
        ),
      );
    }

    pw.TableRow totalRow(String label, String value, {bool emphasize = false}) {
      final style = pw.TextStyle(fontWeight: emphasize ? pw.FontWeight.bold : pw.FontWeight.normal);
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(label, textAlign: pw.TextAlign.right, style: style),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(value, textAlign: pw.TextAlign.right, style: style),
          ),
        ],
      );
    }

    pw.Widget buildHeader() {
      final title = isInvoiceMode ? 'INVOICE SERVIS' : 'TANDA TERIMA SERVIS';
      final paymentMethod = widget.transaction?.paymentMethod.replaceAll('-', ' ').toUpperCase() ?? '-';
      final invoiceNumber = widget.transaction?.invoice.isNotEmpty == true
          ? widget.transaction!.invoice
          : widget.service.serviceNumber;

      if (isThermal) {
        return pw.Column(
          children: [
            pw.Text(_storeName.toUpperCase(), textAlign: pw.TextAlign.center, style: titleStyle),
            if (_storeAddress.isNotEmpty) pw.Text(_storeAddress, textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 6),
            pw.Text('$title #$invoiceNumber', textAlign: pw.TextAlign.center),
            pw.Text('TGL: ${_dateFormat(widget.transaction?.date ?? widget.service.createdAt)}', textAlign: pw.TextAlign.center),
            pw.Text('CUST: ${widget.service.customerName.toUpperCase()}', textAlign: pw.TextAlign.center),
            pw.Text('METODE: $paymentMethod', textAlign: pw.TextAlign.center),
          ],
        );
      }

      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(_storeName.toUpperCase(), style: titleStyle),
                if (_storeAddress.isNotEmpty) pw.Text(_storeAddress),
                pw.Text('METODE: $paymentMethod'),
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('NO: $invoiceNumber'),
              pw.Text('TGL: ${_dateFormat(widget.transaction?.date ?? widget.service.createdAt)}'),
              pw.Text('CUST: ${widget.service.customerName.toUpperCase()}'),
            ],
          ),
        ],
      );
    }

    pw.Widget buildItemsTable() {
      if (isReceiptMode) {
        return pw.Table(
          columnWidths: const {
            0: pw.FlexColumnWidth(1.2),
            1: pw.FlexColumnWidth(5.9),
          },
          children: [
            pw.TableRow(children: [cell('QTY', header: true), cell('DESKRIPSI', header: true)]),
            ...(hasItems
                ? items.map(
                    (item) => pw.TableRow(
                      children: [
                        cell('${item.quantity}', center: true),
                        cell(item.name.isEmpty ? 'JASA SERVICE' : item.name.toUpperCase()),
                      ],
                    ),
                  )
                : [
                    pw.TableRow(
                      children: [
                        cell('1', center: true),
                        cell('JASA SERVICE\nUNIT: ${widget.service.deviceName.toUpperCase()}'),
                      ],
                    ),
                  ]),
          ],
        );
      }

      return pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(1.2),
          1: pw.FlexColumnWidth(3.7),
          2: pw.FlexColumnWidth(2.2),
        },
        children: [
          pw.TableRow(
            children: [
              cell('QTY', header: true),
              cell('DESKRIPSI', header: true),
              cell('TOTAL', header: true, alignRight: true),
            ],
          ),
          ...(hasItems
              ? items.map(
                  (item) => pw.TableRow(
                    children: [
                      cell('${item.quantity}', center: true),
                      cell(item.name.isEmpty ? 'JASA SERVICE' : item.name.toUpperCase()),
                      cell(_money(item.lineTotal), alignRight: true),
                    ],
                  ),
                )
              : [
                  pw.TableRow(
                    children: [
                      cell('1', center: true),
                      cell('JASA SERVICE\nUNIT: ${widget.service.deviceName.toUpperCase()}'),
                      cell(_money(widget.service.finalCost), alignRight: true),
                    ],
                  ),
                ]),
        ],
      );
    }

    pw.Widget buildTotals() {
      if (isReceiptMode) {
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                'DEVICE: ${widget.service.deviceName.toUpperCase()}\nKELUHAN: ${widget.service.complaint.toUpperCase()}',
              ),
            ),
          ],
        );
      }

      final subtotal = widget.transaction?.subtotal ?? widget.service.finalCost;
      final total = widget.transaction?.total ?? widget.service.finalCost;

      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (!isThermal)
            pw.Expanded(
              child: pw.Text(
                'DEVICE: ${widget.service.deviceName.toUpperCase()}\nKELUHAN: ${widget.service.complaint.toUpperCase()}',
              ),
            ),
          pw.Expanded(
            child: pw.Table(
              children: [
                totalRow('SUBTOTAL:', _money(subtotal)),
                totalRow('TOTAL:', _money(total), emphasize: true),
                totalRow('DEPOSIT:', _money(widget.service.estimatedCost)),
                totalRow('SISA:', _money((total - widget.service.estimatedCost).clamp(0, total))),
              ],
            ),
          ),
        ],
      );
    }

    pw.Widget buildTrackingQr() {
      final url = _progressTrackingUrl;
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'CEK PROGRES PEKERJAAN ONLINE',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: url,
              width: isThermal ? 110 : 150,
              height: isThermal ? 110 : 150,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            url,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      );
    }

    pw.Widget signBox(String title, String name) {
      return pw.Column(
        children: [
          pw.Text('$title,', textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 50),
          pw.Text('($name)', textAlign: pw.TextAlign.center),
        ],
      );
    }

    pw.Widget buildSignature() {
      return pw.Row(
        children: [
          pw.Expanded(child: signBox('HORMAT KAMI', 'ADMIN')),
          pw.SizedBox(width: 24),
          pw.Expanded(child: signBox('CUSTOMER', widget.service.customerName.toUpperCase())),
        ],
      );
    }

    pw.Widget buildThermalFooter() {
      return pw.Column(
        children: [
          pdfLine(dashed: true),
          pw.SizedBox(height: 8),
          pw.Text('TERIMA KASIH ATAS KEPERCAYAAN ANDA', textAlign: pw.TextAlign.center),
          pw.Text('* KLAIM GARANSI WAJIB SERTAKAN NOTA INI *', textAlign: pw.TextAlign.center),
          pw.Text('DICETAK: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', textAlign: pw.TextAlign.center),
        ],
      );
    }

    final content = pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.symmetric(horizontal: isThermal ? 14 : 22, vertical: 18),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1.5)),
      child: pw.DefaultTextStyle(
        style: baseTextStyle,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            buildHeader(),
            pw.SizedBox(height: 8),
            pdfLine(doubleLine: true),
            pw.SizedBox(height: 8),
            buildItemsTable(),
            pw.SizedBox(height: 8),
            pdfLine(dashed: true),
            pw.SizedBox(height: 8),
            buildTotals(),
            if (isReceiptMode) ...[
              pw.SizedBox(height: 12),
              pdfLine(dashed: true),
              pw.SizedBox(height: 10),
              buildTrackingQr(),
            ],
            pw.SizedBox(height: 16),
            if (!isThermal) buildSignature() else buildThermalFooter(),
          ],
        ),
      ),
    );

    final format = switch (_selectedFormat) {
      ReceiptFormat.standard => PdfPageFormat.a4,
      ReceiptFormat.thermal80 => PdfPageFormat(80 * PdfPageFormat.mm, (170 + (hasItems ? items.length * 10 : 18)) * PdfPageFormat.mm),
      ReceiptFormat.thermal58 => PdfPageFormat(58 * PdfPageFormat.mm, (170 + (hasItems ? items.length * 10 : 18)) * PdfPageFormat.mm),
    };

    if (isThermal) {
      doc.addPage(
        pw.Page(
          pageFormat: format,
          margin: const pw.EdgeInsets.all(8),
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          build: (_) => content,
        ),
      );
    } else {
      doc.addPage(
        pw.MultiPage(
          pageFormat: format,
          margin: const pw.EdgeInsets.all(20),
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          build: (_) => [content],
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }
}
