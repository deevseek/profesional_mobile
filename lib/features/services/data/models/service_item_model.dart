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
    final product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final qty = _asInt(json['qty']);
    final productPrice = _asInt(product['price']);
    final parsedPrice = _asInt(json['price']);
    final price = parsedPrice > 0 ? parsedPrice : productPrice;

    return _$ServiceItemModelFromJson({
      ...json,
      'id': _asString(json['id']),
      'service_id': _asString(json['service_id']),
      'product_id': _asString(json['product_id']),
      'product_name': _asString(json['product_name']).isNotEmpty
          ? _asString(json['product_name'])
          : _asString(product['name']),
      'qty': qty,
      'price': price,
      'subtotal': _asInt(json['subtotal'] ?? json['total']) > 0 ? _asInt(json['subtotal'] ?? json['total']) : qty * price,
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
