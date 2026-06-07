import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/receipt/receipt_preview_dialog.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';

class ReceiptPreviewPage extends ConsumerWidget {
  const ReceiptPreviewPage({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Struk')),
      body: Center(
        child: FilledButton.icon(
          onPressed: () => showTransactionReceipt(context, ref, transaction),
          icon: const Icon(Icons.receipt_long_rounded),
          label: const Text('Buka Preview Struk'),
        ),
      ),
    );
  }
}
