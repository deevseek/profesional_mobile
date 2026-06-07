import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class UserApiModel extends ApiResourceModel {
  const UserApiModel({required super.raw});
  factory UserApiModel.fromJson(Map<String, dynamic> json) => UserApiModel(raw: json);
}
