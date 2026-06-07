import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class StoreSettingsModel {
  const StoreSettingsModel({
    required this.storeName,
    required this.address,
    required this.phone,
    required this.logo,
    required this.attendanceEnabled,
    required this.requireSelfie,
    required this.requireLocation,
    this.storeHours = '',
    this.transactionPrefix = '',
    this.transactionPadding = 0,
    this.latitude,
    this.longitude,
  });

  final String storeName;
  final String address;
  final String phone;
  final String logo;
  final bool attendanceEnabled;
  final bool requireSelfie;
  final bool requireLocation;
  final String storeHours;
  final String transactionPrefix;
  final int transactionPadding;
  final double? latitude;
  final double? longitude;

  StoreSettingsModel copyWith({
    String? storeName,
    String? address,
    String? phone,
    String? logo,
    bool? attendanceEnabled,
    bool? requireSelfie,
    bool? requireLocation,
    String? storeHours,
    String? transactionPrefix,
    int? transactionPadding,
    double? latitude,
    double? longitude,
  }) {
    return StoreSettingsModel(
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      logo: logo ?? this.logo,
      attendanceEnabled: attendanceEnabled ?? this.attendanceEnabled,
      requireSelfie: requireSelfie ?? this.requireSelfie,
      requireLocation: requireLocation ?? this.requireLocation,
      storeHours: storeHours ?? this.storeHours,
      transactionPrefix: transactionPrefix ?? this.transactionPrefix,
      transactionPadding: transactionPadding ?? this.transactionPadding,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory StoreSettingsModel.fromJson(Map<String, dynamic> json) {
    final data = unwrapDataMap(json);
    return StoreSettingsModel(
      storeName: parseString(data['store_name']),
      address: parseString(data['store_address'] ?? data['address']),
      phone: parseString(data['store_phone'] ?? data['phone']),
      logo: parseString(data['store_logo_path'] ?? data['store_logo'] ?? data['logo']),
      attendanceEnabled: parseBool(data['attendance_enabled'], fallback: true),
      requireSelfie: parseBool(data['attendance_require_selfie']),
      requireLocation: parseBool(data['attendance_require_location']),
      storeHours: parseString(data['store_hours']),
      transactionPrefix: parseString(data['transaction_prefix']),
      transactionPadding: parseInt(data['transaction_padding']),
      latitude: data['store_latitude'] == null ? null : parseDouble(data['store_latitude']),
      longitude: data['store_longitude'] == null ? null : parseDouble(data['store_longitude']),
    );
  }

  factory StoreSettingsModel.empty() => const StoreSettingsModel(storeName: '', address: '', phone: '', logo: '', attendanceEnabled: true, requireSelfie: false, requireLocation: false);
}
