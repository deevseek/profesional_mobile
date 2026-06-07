import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class StockMovementModel extends ApiResourceModel {
  const StockMovementModel({required super.raw});
  factory StockMovementModel.fromJson(Map<String, dynamic> json) => StockMovementModel(raw: json);
}
