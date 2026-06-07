import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class PrintOrderModel extends ApiResourceModel {
  const PrintOrderModel({required super.raw});
  factory PrintOrderModel.fromJson(Map<String, dynamic> json) => PrintOrderModel(raw: json);
}
