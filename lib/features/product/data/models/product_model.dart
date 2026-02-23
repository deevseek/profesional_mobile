import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const ProductModel._();

  const factory ProductModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String sku,
    @Default('') String category,
    @Default(0) int stock,
    @Default(0) int price,
    @Default('') String description,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return _$ProductModelFromJson({
      ...json,
      'id': _asString(json['id']),
      'name': _asString(json['name']),
      'sku': _asString(json['sku']),
      'category': _asString(json['category']),
      'stock': _asInt(json['stock']),
      'price': _asInt(json['price']),
      'description': _asString(json['description']),
    });
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  static int _asInt(dynamic value) {
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
}
