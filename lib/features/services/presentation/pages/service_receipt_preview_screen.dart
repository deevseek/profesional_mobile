import 'package:flutter/material.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_model.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';

class ServiceReceiptPreviewScreen extends StatelessWidget {
  const ServiceReceiptPreviewScreen({
    super.key,
    required this.service,
    this.store = const <String, dynamic>{},
    this.transaction,
  });

  final ServiceModel service;
  final Map<String, dynamic> store;
  final TransactionModel? transaction;

  bool get isInvoiceMode => transaction != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isInvoiceMode ? 'Invoice Service' : 'Tanda Terima Service')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_storeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                if (_storeAddress.isNotEmpty) Text(_storeAddress),
                if (_storePhone.isNotEmpty) Text('Telp: $_storePhone'),
                const Divider(height: 24),
                _row('No Service', service.serviceNumber),
                _row('Customer', service.customerName),
                _row('Device', '${service.deviceName} (${service.deviceType})'),
                _row('Keluhan', service.complaint),
                _row('Deposit', _money(service.estimatedCost)),
                _row('Biaya Jasa', _money(service.finalCost)),
                if (isInvoiceMode) ...[
                  const Divider(height: 24),
                  _row('No Invoice', transaction!.invoice),
                  _row('Subtotal', _money(transaction!.subtotal)),
                  _row('Total', _money(transaction!.total)),
                  const SizedBox(height: 8),
                  const Text('Detail Item', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (transaction!.items.isEmpty)
                    const Text('-', style: TextStyle(color: Color(0xFF667085)))
                  else
                    ...transaction!.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.name.isEmpty ? '-' : item.name)),
                            Text('${item.quantity} x ${_money(item.price)}'),
                            const SizedBox(width: 8),
                            Text(_money(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _storeName => (store['name'] ?? '').toString().trim().isEmpty
      ? 'Profesional Servis'
      : (store['name'] ?? '').toString();

  String get _storeAddress => (store['address'] ?? '').toString();
  String get _storePhone => (store['phone'] ?? '').toString();

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92, child: Text(label, style: const TextStyle(color: Color(0xFF667085)))),
          const Text(': '),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  String _money(int amount) {
    final normalized = amount.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < normalized.length; i++) {
      final fromEnd = normalized.length - i;
      buffer.write(normalized[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp $buffer';
  }
}
