import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_item_model.freezed.dart';
part 'service_item_model.g.dart';

@freezed
class ServiceItemModel with _$ServiceItemModel {
  const ServiceItemModel._();

  const factory ServiceItemModel({
    @Default('') String id,
    @JsonKey(name: 'service_id') @Default('') String serviceId,
    @JsonKey(name: 'product_id') @Default('') String productId,
    @JsonKey(name: 'product_name') @Default('') String productName,
    @Default(0) int qty,
    @Default(0) int price,
    @Default(0) int subtotal,
  }) = _ServiceItemModel;

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return _$ServiceItemModelFromJson({
      ...json,
      'id': _asString(json['id']),
      'service_id': _asString(json['service_id']),
      'product_id': _asString(json['product_id']),
      'product_name': _asString(json['product_name']),
      'qty': _asInt(json['qty']),
      'price': _asInt(json['price']),
      'subtotal': _asInt(json['subtotal']),
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
