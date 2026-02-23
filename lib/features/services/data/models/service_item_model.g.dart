// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'service_item_model.dart';

ServiceItemModel _$ServiceItemModelFromJson(Map<String, dynamic> json) {
  return _ServiceItemModel(
    id: (json['id'] ?? '').toString(),
    serviceId: (json['service_id'] ?? '').toString(),
    productId: (json['product_id'] ?? '').toString(),
    productName: (json['product_name'] ?? '').toString(),
    qty: (json['qty'] is num) ? (json['qty'] as num).toInt() : int.tryParse((json['qty'] ?? '0').toString()) ?? 0,
    price: (json['price'] is num)
        ? (json['price'] as num).toInt()
        : int.tryParse((json['price'] ?? '0').toString()) ?? 0,
    subtotal: (json['subtotal'] is num)
        ? (json['subtotal'] as num).toInt()
        : int.tryParse((json['subtotal'] ?? '0').toString()) ?? 0,
  );
}

Map<String, dynamic> _$ServiceItemModelToJson(_ServiceItemModel instance) => <String, dynamic>{
  'id': instance.id,
  'service_id': instance.serviceId,
  'product_id': instance.productId,
  'product_name': instance.productName,
  'qty': instance.qty,
  'price': instance.price,
  'subtotal': instance.subtotal,
};
