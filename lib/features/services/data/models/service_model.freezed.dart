// coverage:ignore-file
// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'service_model.dart';

mixin _$ServiceModel {
  String get id => throw UnimplementedError();
  String get serviceNumber => throw UnimplementedError();
  String get customerId => throw UnimplementedError();
  String get customerName => throw UnimplementedError();
  String get deviceName => throw UnimplementedError();
  String get deviceType => throw UnimplementedError();
  String get complaint => throw UnimplementedError();
  String get diagnosis => throw UnimplementedError();
  String get status => throw UnimplementedError();
  String get technicianId => throw UnimplementedError();
  String get technicianName => throw UnimplementedError();
  int get estimatedCost => throw UnimplementedError();
  int get finalCost => throw UnimplementedError();
  DateTime? get createdAt => throw UnimplementedError();
  DateTime? get updatedAt => throw UnimplementedError();
  List<ServiceItemModel> get items => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

class _ServiceModel extends ServiceModel {
  const _ServiceModel({
    this.id = '',
    this.serviceNumber = '',
    this.customerId = '',
    this.customerName = '',
    this.deviceName = '',
    this.deviceType = '',
    this.complaint = '',
    this.diagnosis = '',
    this.status = 'pending',
    this.technicianId = '',
    this.technicianName = '',
    this.estimatedCost = 0,
    this.finalCost = 0,
    this.createdAt,
    this.updatedAt,
    this.items = const <ServiceItemModel>[],
  }) : super._();

  @override
  final String id;
  @override
  final String serviceNumber;
  @override
  final String customerId;
  @override
  final String customerName;
  @override
  final String deviceName;
  @override
  final String deviceType;
  @override
  final String complaint;
  @override
  final String diagnosis;
  @override
  final String status;
  @override
  final String technicianId;
  @override
  final String technicianName;
  @override
  final int estimatedCost;
  @override
  final int finalCost;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final List<ServiceItemModel> items;

  @override
  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);
}
