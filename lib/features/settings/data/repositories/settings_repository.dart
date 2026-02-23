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

  Future<void> upsertBatch(StoreSettingsModel settings) async {
    final payload = {
      'settings': [
        {'key': 'store_name', 'value': settings.storeName},
        {'key': 'store_address', 'value': settings.address},
        {'key': 'store_phone', 'value': settings.phone},
        {'key': 'store_logo', 'value': settings.logo},
        {'key': 'attendance_enabled', 'value': settings.attendanceEnabled},
        {'key': 'attendance_require_selfie', 'value': settings.requireSelfie},
        {'key': 'attendance_require_location', 'value': settings.requireLocation},
      ],
    };

    await _dio.post('/settings', data: payload);
  }
}
