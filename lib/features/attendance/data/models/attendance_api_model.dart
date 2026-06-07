import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';

class AttendanceModel extends ApiResourceModel {
  const AttendanceModel({required super.raw});
  factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(raw: json);
}
