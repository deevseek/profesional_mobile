import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class FinanceModel {
  const FinanceModel({required this.id, required this.type, required this.category, required this.nominal, required this.note, required this.recordedAt, required this.source});
  final String id;
  final String type;
  final String category;
  final double nominal;
  final String note;
  final DateTime? recordedAt;
  final String source;
  factory FinanceModel.fromJson(Map<String, dynamic> json) => FinanceModel(id: parseString(json['id']), type: parseString(json['type']), category: parseString(json['category'], fallback: '-'), nominal: parseDouble(json['nominal'] ?? json['amount']), note: parseString(json['note'] ?? json['notes']), recordedAt: parseDateTime(json['recorded_at'] ?? json['date']), source: parseString(json['source']));
  Map<String, dynamic> toJson() => {'type': type, 'category': category, 'nominal': nominal, 'note': note, 'recorded_at': recordedAt?.toIso8601String().split('T').first, 'source': source};
}

class FinanceSummaryModel {
  const FinanceSummaryModel({required this.raw});
  final Map<String, dynamic> raw;
  double get posIncome => parseDouble(raw['pos_income']);
  double get serviceIncome => parseDouble(raw['service_income']);
  double get totalIncome => parseDouble(raw['total_income']);
  double get totalHpp => parseDouble(raw['total_hpp']);
  double get operationalExpense => parseDouble(raw['operational_expense']);
  double get grossProfit => parseDouble(raw['gross_profit']);
  double get netProfit => parseDouble(raw['net_profit']);
  double get todayIncome => parseDouble(raw['today_income']);
  double get todayExpense => parseDouble(raw['today_expense']);
  double get inventoryAssetValue => parseDouble(raw['inventory_asset_value']);
  double get cashAccountBalance => parseDouble(raw['cash_account_balance']);
  factory FinanceSummaryModel.fromJson(Map<String, dynamic> json) => FinanceSummaryModel(raw: json);
}

class FinanceListResponse {
  const FinanceListResponse({required this.items, required this.meta, required this.links, required this.summary, required this.period});
  final List<FinanceModel> items;
  final Map<String, dynamic> meta;
  final Map<String, dynamic> links;
  final FinanceSummaryModel summary;
  final Map<String, dynamic> period;
}
