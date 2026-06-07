import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class EmployeeModel extends ApiResourceModel {
  const EmployeeModel({required super.raw});
  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(raw: json);
}
