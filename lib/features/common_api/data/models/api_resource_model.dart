import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class ApiResourceModel {
  const ApiResourceModel({required this.raw});

  final Map<String, dynamic> raw;

  String get id => parseString(raw['id'] ?? raw['uuid'] ?? raw['code']);
  String get name => parseString(raw['name'] ?? raw['title'] ?? raw['category'] ?? raw['store_name'], fallback: '-');
  String get description => parseString(raw['description'] ?? raw['note'] ?? raw['notes'] ?? raw['message']);
  String get status => parseString(raw['status'] ?? raw['payment_status'] ?? raw['type']);
  DateTime? get createdAt => parseDateTime(raw['created_at']);
  DateTime? get updatedAt => parseDateTime(raw['updated_at']);

  factory ApiResourceModel.fromJson(Map<String, dynamic> json) => ApiResourceModel(raw: json);
}
