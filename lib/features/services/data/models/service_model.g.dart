// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'service_model.dart';

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) {
  final rawItems = json['items'];
  return _ServiceModel(
    id: (json['id'] ?? '').toString(),
    serviceNumber: (json['service_number'] ?? '').toString(),
    customerId: (json['customer_id'] ?? '').toString(),
    customerName: (json['customer_name'] ?? '').toString(),
    deviceName: (json['device_name'] ?? '').toString(),
    deviceType: (json['device_type'] ?? '').toString(),
    complaint: (json['complaint'] ?? '').toString(),
    diagnosis: (json['diagnosis'] ?? '').toString(),
    status: (json['status'] == null || json['status'].toString().isEmpty) ? 'pending' : json['status'].toString(),
    technicianId: (json['technician_id'] ?? '').toString(),
    technicianName: (json['technician_name'] ?? '').toString(),
    estimatedCost: (json['estimated_cost'] is num)
        ? (json['estimated_cost'] as num).toInt()
        : int.tryParse((json['estimated_cost'] ?? '0').toString()) ?? 0,
    finalCost: (json['final_cost'] is num)
        ? (json['final_cost'] as num).toInt()
        : int.tryParse((json['final_cost'] ?? '0').toString()) ?? 0,
    createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'].toString()),
    updatedAt: json['updated_at'] == null ? null : DateTime.tryParse(json['updated_at'].toString()),
    items: rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(ServiceItemModel.fromJson)
            .toList(growable: false)
        : const <ServiceItemModel>[],
  );
}

Map<String, dynamic> _$ServiceModelToJson(_ServiceModel instance) => <String, dynamic>{
  'id': instance.id,
  'service_number': instance.serviceNumber,
  'customer_id': instance.customerId,
  'customer_name': instance.customerName,
  'device_name': instance.deviceName,
  'device_type': instance.deviceType,
  'complaint': instance.complaint,
  'diagnosis': instance.diagnosis,
  'status': instance.status,
  'technician_id': instance.technicianId,
  'technician_name': instance.technicianName,
  'estimated_cost': instance.estimatedCost,
  'final_cost': instance.finalCost,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'items': instance.items.map((e) => e.toJson()).toList(growable: false),
};
