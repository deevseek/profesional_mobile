import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class PermissionModel extends ApiResourceModel {
  const PermissionModel({required super.raw});
  factory PermissionModel.fromJson(Map<String, dynamic> json) => PermissionModel(raw: json);
}
