import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/tenant/tenant_state_provider.dart';
import 'package:profesionalservis_mobile/tenant/tenant_url_utils.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openPosReceiptUrl(
  BuildContext context,
  WidgetRef ref,
  int transactionId,
) async {
  if (transactionId <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID transaksi tidak valid.')),
    );
    return;
  }

  final tenantApiUrl = ref.read(tenantStateProvider).baseUrl ?? defaultTenantApiBaseUrl;
  final receiptUrl = buildPosReceiptUrl(
    apiUrl: tenantApiUrl,
    transactionId: transactionId,
  );
  final uri = Uri.parse(receiptUrl);
  final mode = kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication;

  final opened = await launchUrl(uri, mode: mode);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal membuka struk Laravel: $receiptUrl')),
    );
  }
}
