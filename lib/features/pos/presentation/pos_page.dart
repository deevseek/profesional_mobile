import 'dart:math';

import 'package:flutter/material.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  double _amountDue = 0;

  @override
  void initState() {
    super.initState();
    _totalController.addListener(_recalculateAmountDue);
    _discountController.addListener(_recalculateAmountDue);
  }

  @override
  void dispose() {
    _totalController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Ringkasan Pembayaran',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _totalController,
            decoration: const InputDecoration(
              labelText: 'Total Belanja',
              prefixIcon: Icon(Icons.receipt_long_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _discountController,
            decoration: const InputDecoration(
              labelText: 'Diskon',
              prefixIcon: Icon(Icons.percent_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Jumlah Bayar',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Text(
                    _formatAmount(_amountDue),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _recalculateAmountDue() {
    final totalAmount = _parseAmount(_totalController.text);
    final discountAmount = _parseAmount(_discountController.text);
    final nextAmountDue = max(0, totalAmount - discountAmount);
    if (nextAmountDue == _amountDue) {
      return;
    }
    setState(() {
      _amountDue = nextAmountDue;
    });
  }

  double _parseAmount(String raw) {
    final sanitized = raw.replaceAll(',', '.').trim();
    return double.tryParse(sanitized) ?? 0;
  }

  String _formatAmount(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }
}
