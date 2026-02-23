import 'package:flutter/material.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_model.dart';

class ServiceReceiptPreviewScreen extends StatelessWidget {
  const ServiceReceiptPreviewScreen({super.key, required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Tanda Terima')),
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
                const Text('Profesional Servis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const Text('Service receipt preview'),
                const Divider(height: 24),
                _row('No Service', service.serviceNumber),
                _row('Customer', service.customerName),
                _row('Device', '${service.deviceName} (${service.deviceType})'),
                _row('Keluhan', service.complaint),
                _row('Estimasi', 'Rp ${service.estimatedCost}'),
                _row('Final', 'Rp ${service.finalCost}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
}
