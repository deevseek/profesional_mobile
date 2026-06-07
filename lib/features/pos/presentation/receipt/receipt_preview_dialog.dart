import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/receipt_payload_model.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_url_launcher.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_document_builder.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_format_selector.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_pdf_service.dart';

Future<void> showReceiptPreview(BuildContext context, ReceiptPayloadModel payload) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ReceiptPreviewDialog(payload: payload),
  );
}

Future<void> showTransactionReceipt(BuildContext context, WidgetRef ref, int transactionId) {
  return openPosReceiptUrl(context, ref, transactionId);
}

class ReceiptPreviewDialog extends ConsumerStatefulWidget {
  const ReceiptPreviewDialog({super.key, required this.payload});

  final ReceiptPayloadModel payload;

  @override
  ConsumerState<ReceiptPreviewDialog> createState() => _ReceiptPreviewDialogState();
}

class _ReceiptPreviewDialogState extends ConsumerState<ReceiptPreviewDialog> {
  ReceiptFormat _format = ReceiptFormat.standard;
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  const Expanded(child: Text('Preview Struk / Invoice', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ReceiptFormatSelector(value: _format, onChanged: (value) => setState(() => _format = value)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [ReceiptDocumentBuilder(payload: widget.payload, format: _format)],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isPrinting ? null : _sharePdf,
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text('Simpan PDF'),
                    ),
                    FilledButton.icon(
                      onPressed: _isPrinting ? null : _print,
                      icon: _isPrinting
                          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.print_rounded),
                      label: const Text('Cetak Invoice'),
                    ),
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Tutup')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _print() async {
    final invoice = widget.payload.transaction.invoiceNumber;
    await _guardedPrint(() async {
      await Printing.layoutPdf(
        name: invoice.isEmpty ? 'invoice-pos' : invoice,
        onLayout: (_) => ReceiptPdfService.build(payload: widget.payload, receiptFormat: _format),
      );
    });
  }

  Future<void> _sharePdf() async {
    final invoice = widget.payload.transaction.invoiceNumber;
    await _guardedPrint(() async {
      final bytes = await ReceiptPdfService.build(payload: widget.payload, receiptFormat: _format);
      await Printing.sharePdf(bytes: bytes, filename: '${invoice.isEmpty ? 'invoice-pos' : invoice}.pdf');
    });
  }

  Future<void> _guardedPrint(Future<void> Function() action) async {
    setState(() => _isPrinting = true);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka print/PDF: $error')));
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }
}
