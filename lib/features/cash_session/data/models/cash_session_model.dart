import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class CashSessionModel extends ApiResourceModel {
  const CashSessionModel({required super.raw});
  factory CashSessionModel.fromJson(Map<String, dynamic> json) => CashSessionModel(raw: json);
}
