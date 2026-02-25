import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_item_model.dart';

part 'service_model.freezed.dart';
part 'service_model.g.dart';

@freezed
class ServiceModel with _$ServiceModel {
  const ServiceModel._();

  const factory ServiceModel({
    @Default('') String id,
    @JsonKey(name: 'service_number') @Default('') String serviceNumber,
    @JsonKey(name: 'customer_id') @Default('') String customerId,
    @JsonKey(name: 'customer_name') @Default('') String customerName,
    @JsonKey(name: 'device_name') @Default('') String deviceName,
    @JsonKey(name: 'device_type') @Default('') String deviceType,
    @Default('') String complaint,
    @Default('') String diagnosis,
    @Default('pending') String status,
    @JsonKey(name: 'technician_id') @Default('') String technicianId,
    @JsonKey(name: 'technician_name') @Default('') String technicianName,
    @JsonKey(name: 'estimated_cost') @Default(0) int estimatedCost,
    @JsonKey(name: 'final_cost') @Default(0) int finalCost,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @Default(<ServiceItemModel>[]) List<ServiceItemModel> items,
  }) = _ServiceModel;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final customer = json['customer'] is Map<String, dynamic>
        ? json['customer'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return _$ServiceModelFromJson({
      ...json,
      'id': _asString(json['id']),
      'service_number': _asString(json['service_number']).isNotEmpty
          ? _asString(json['service_number'])
          : _buildServiceNumber(json['id']),
      'customer_id': _asString(json['customer_id']),
      'customer_name': _asString(json['customer_name']).isNotEmpty
          ? _asString(json['customer_name'])
          : _asString(customer['name']),
      'device_name': _asString(json['device']),
      'device_type': _asString(json['model']),
      'complaint': _asString(json['complaint']),
      'diagnosis': _asString(json['diagnosis']),
      'status': _normalizeStatus(_asString(json['status'])),
      'technician_id': _asString(json['technician_id']),
      'technician_name': _asString(json['technician_name']),
      'estimated_cost': _asInt(json['deposit']),
      'final_cost': _asInt(json['service_fee']),
      'created_at': json['created_at'] ?? json['received_at'],
      'updated_at': json['updated_at'],
      'items': rawItems is List ? rawItems : <Map<String, dynamic>>[],
    });
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

String _buildServiceNumber(dynamic id) {
  final numericId = _asInt(id);
  if (numericId <= 0) {
    return '';
  }
  final year = DateTime.now().year;
  return 'SVC-$year-${numericId.toString().padLeft(4, '0')}';
}

String _normalizeStatus(String rawStatus) {
  switch (rawStatus.toLowerCase()) {
    case 'menunggu':
      return 'menunggu';
    case 'diagnosa':
      return 'diagnosa';
    case 'dikerjakan':
      return 'dikerjakan';
    case 'selesai':
      return 'selesai';
    case 'diambil':
      return 'diambil';
    case 'pending':
      return 'menunggu';
    case 'checking':
      return 'diagnosa';
    case 'progress':
      return 'dikerjakan';
    case 'done':
      return 'selesai';
    case 'delivered':
      return 'diambil';
    default:
      return rawStatus.isEmpty ? 'menunggu' : rawStatus;
  }
}
