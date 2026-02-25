class ServiceTrackingModel {
  const ServiceTrackingModel({
    this.serviceNumber = '',
    this.progressUrl = '',
    this.qrUrl = '',
  });

  final String serviceNumber;
  final String progressUrl;
  final String qrUrl;

  factory ServiceTrackingModel.fromJson(Map<String, dynamic> json) {
    return ServiceTrackingModel(
      serviceNumber: _asString(json['service_number']),
      progressUrl: _asString(json['progress_url']),
      qrUrl: _asString(json['qr_url']),
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';
