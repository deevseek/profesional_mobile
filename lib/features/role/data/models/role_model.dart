import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class RoleModel extends ApiResourceModel {
  const RoleModel({required super.raw});
  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(raw: json);
}
