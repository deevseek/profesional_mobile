import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/settings/data/models/store_settings_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(dioProvider)),
);

class SettingsRepository {
  SettingsRepository(this._dio);

  final Dio _dio;

  Future<StoreSettingsModel> getSettings() async {
    final response = await _dio.get<Map<String, dynamic>>('/settings');
    return StoreSettingsModel.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> upsertBatch(StoreSettingsModel settings) async {
    final payload = {
      'store_name': settings.storeName,
      'store_address': settings.address,
      'store_phone': settings.phone,
      'store_hours': settings.storeHours,
      'transaction_prefix': settings.transactionPrefix,
      'transaction_padding': settings.transactionPadding,
      'store_logo_path': settings.logo,
      if (settings.latitude != null) 'store_latitude': settings.latitude,
      if (settings.longitude != null) 'store_longitude': settings.longitude,
      'attendance_enabled': settings.attendanceEnabled,
      'attendance_require_selfie': settings.requireSelfie,
      'attendance_require_location': settings.requireLocation,
    };

    await _dio.post('/settings', data: payload);
  }
}
