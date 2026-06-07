import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class ServiceLogModel extends ApiResourceModel {
  const ServiceLogModel({required super.raw});
  factory ServiceLogModel.fromJson(Map<String, dynamic> json) => ServiceLogModel(raw: json);
}
