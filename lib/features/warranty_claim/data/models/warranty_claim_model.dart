import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class WarrantyClaimModel extends ApiResourceModel {
  const WarrantyClaimModel({required super.raw});
  factory WarrantyClaimModel.fromJson(Map<String, dynamic> json) => WarrantyClaimModel(raw: json);
}
