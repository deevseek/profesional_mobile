import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/app_config/data/models/app_config_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';

final appConfigRepositoryProvider = Provider<AppConfigRepository>((ref) {
  return AppConfigRepository(ref.watch(dioProvider));
});

class AppConfigRepository {
  const AppConfigRepository(this._dio);

  final Dio _dio;

  Future<AppConfigModel> getAppConfig() async {
    final response = await _dio.get<Map<String, dynamic>>('/app-config');
    return AppConfigModel.fromJson(response.data ?? <String, dynamic>{});
  }
}
