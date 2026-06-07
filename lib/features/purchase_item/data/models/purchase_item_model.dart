import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class PurchaseItemModel extends ApiResourceModel {
  const PurchaseItemModel({required super.raw});
  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) => PurchaseItemModel(raw: json);
}
