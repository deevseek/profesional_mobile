const defaultTenantApiBaseUrl = 'https://profesionalservis.my.id/api/v1';

String webBaseUrlFromApiUrl(String apiUrl) {
  final normalized = apiUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  if (normalized.isEmpty) {
    return webBaseUrlFromApiUrl(defaultTenantApiBaseUrl);
  }
  return normalized.replaceFirst(RegExp(r'/api/v1/?$'), '');
}

String buildPosReceiptUrl({required String apiUrl, required int transactionId}) {
  final tenantWebBaseUrl = webBaseUrlFromApiUrl(apiUrl);
  return '$tenantWebBaseUrl/pos/transactions/$transactionId/receipt';
}
