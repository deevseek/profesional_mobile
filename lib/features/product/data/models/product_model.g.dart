// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'product_model.dart';

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return _ProductModel(
    id: (json['id'] ?? '').toString(),
    name: ((json['name'] ?? '-').toString().trim().isEmpty) ? '-' : (json['name'] ?? '-').toString(),
    sku: (json['sku'] ?? '').toString(),
    category: (json['category'] ?? '').toString(),
    stock: (json['stock'] is num)
        ? (json['stock'] as num).toInt()
        : int.tryParse((json['stock'] ?? '0').toString()) ?? 0,
    price: (json['price'] is num)
        ? (json['price'] as num).toInt()
        : int.tryParse((json['price'] ?? '0').toString()) ?? 0,
    description: (json['description'] ?? '').toString(),
  );
}

Map<String, dynamic> _$ProductModelToJson(_ProductModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sku': instance.sku,
  'category': instance.category,
  'stock': instance.stock,
  'price': instance.price,
  'description': instance.description,
};
