import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class TransactionItemApiModel extends ApiResourceModel {
  const TransactionItemApiModel({required super.raw});
  factory TransactionItemApiModel.fromJson(Map<String, dynamic> json) => TransactionItemApiModel(raw: json);
}
