import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/dashboard_summary_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioProvider));
});

class DashboardRepository {
  const DashboardRepository(this._dio);

  final Dio _dio;

  Future<DashboardSummaryModel> getSummary() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/dashboard/summary', queryParameters: {'days': 7});

    final data = response.data;
    if (data == null) {
      throw const FormatException('Response dashboard kosong.');
    }

    final payload =
        (data['data'] is Map<String, dynamic>) ? data['data'] as Map<String, dynamic> : data;

    return DashboardSummaryModel.fromJson(payload);
  }
}
