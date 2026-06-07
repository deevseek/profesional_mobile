import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class ServiceItemModel extends ApiResourceModel {
  const ServiceItemModel({required super.raw});
  factory ServiceItemModel.fromJson(Map<String, dynamic> json) => ServiceItemModel(raw: json);
}
