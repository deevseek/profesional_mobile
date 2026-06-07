import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class WarrantyModel extends ApiResourceModel {
  const WarrantyModel({required super.raw});
  factory WarrantyModel.fromJson(Map<String, dynamic> json) => WarrantyModel(raw: json);
}
