import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class PurchaseModel extends ApiResourceModel {
  const PurchaseModel({required super.raw});
  factory PurchaseModel.fromJson(Map<String, dynamic> json) => PurchaseModel(raw: json);
}
