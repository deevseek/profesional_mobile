import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/finance/data/models/finance_model.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';
import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) => FinanceRepository(ref.watch(dioProvider)));
class FinanceRepository {
  const FinanceRepository(this._dio);
  final Dio _dio;
  Future<FinanceListResponse> getFinances({int page = 1, String? search, String? month, String? date, String? type}) async {
    final body = (await _dio.get<Map<String, dynamic>>('/finances', queryParameters: {'page': page, if (search != null && search.isNotEmpty) 'search': search, if (month != null && month.isNotEmpty) 'month': month, if (date != null && date.isNotEmpty) 'date': date, if (type != null && type.isNotEmpty) 'type': type})).data ?? <String, dynamic>{};
    return FinanceListResponse(items: unwrapDataList(body).map(FinanceModel.fromJson).toList(growable: false), meta: parseMap(body['meta']), links: parseMap(body['links']), summary: FinanceSummaryModel.fromJson(parseMap(body['summary'])), period: parseMap(body['period']));
  }
  Future<FinanceModel> getFinance(String id) async => FinanceModel.fromJson(unwrapDataMap((await _dio.get<Map<String, dynamic>>('/finances/$id')).data));
  Future<void> addFinance(FinanceModel finance) => _dio.post<void>('/finances', data: finance.toJson());
  Future<void> editFinance(String id, FinanceModel finance) => _dio.patch<void>('/finances/$id', data: finance.toJson());
  Future<void> deleteFinance(String id) => _dio.delete<void>('/finances/$id');
}
