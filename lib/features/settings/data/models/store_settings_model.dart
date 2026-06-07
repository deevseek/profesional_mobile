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
    this.bankAccount = '',
    this.npwp = '',
    this.warrantyTerms = '',
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
  final String bankAccount;
  final String npwp;
  final String warrantyTerms;

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
    String? bankAccount,
    String? npwp,
    String? warrantyTerms,
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
      bankAccount: bankAccount ?? this.bankAccount,
      npwp: npwp ?? this.npwp,
      warrantyTerms: warrantyTerms ?? this.warrantyTerms,
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
      bankAccount: parseString(data['bank_account'] ?? data['store_bank_account'] ?? data['rekening']),
      npwp: parseString(data['npwp'] ?? data['store_npwp']),
      warrantyTerms: parseString(data['warranty_terms'] ?? data['terms_and_conditions']),
    );
  }

  factory StoreSettingsModel.empty() => const StoreSettingsModel(storeName: '', address: '', phone: '', logo: '', attendanceEnabled: true, requireSelfie: false, requireLocation: false);
}
