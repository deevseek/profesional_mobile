class StoreSettingsModel {
  const StoreSettingsModel({
    required this.storeName,
    required this.address,
    required this.phone,
    required this.logo,
    required this.attendanceEnabled,
    required this.requireSelfie,
    required this.requireLocation,
  });

  final String storeName;
  final String address;
  final String phone;
  final String logo;
  final bool attendanceEnabled;
  final bool requireSelfie;
  final bool requireLocation;

  StoreSettingsModel copyWith({
    String? storeName,
    String? address,
    String? phone,
    String? logo,
    bool? attendanceEnabled,
    bool? requireSelfie,
    bool? requireLocation,
  }) {
    return StoreSettingsModel(
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      logo: logo ?? this.logo,
      attendanceEnabled: attendanceEnabled ?? this.attendanceEnabled,
      requireSelfie: requireSelfie ?? this.requireSelfie,
      requireLocation: requireLocation ?? this.requireLocation,
    );
  }

  factory StoreSettingsModel.empty() {
    return const StoreSettingsModel(
      storeName: '',
      address: '',
      phone: '',
      logo: '',
      attendanceEnabled: true,
      requireSelfie: false,
      requireLocation: false,
    );
  }
}
