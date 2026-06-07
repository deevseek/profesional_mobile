import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const ProductModel._();

  const factory ProductModel({
    @Default('') String id,
    @Default('-') String name,
    @Default('') String sku,
    @Default('') String category,
    @Default(0) int stock,
    @Default(0) int price,
    @Default('') String description,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];

    return _$ProductModelFromJson({
      ...json,
      'id': _asString(json['id']),
      'name': _asString(json['name'], fallback: '-'),
      'sku': _asString(json['sku']),
      'category': _parseCategory(rawCategory ?? json['category_id']),
      'stock': _asInt(json['stock']),
      'price': _asInt(json['price']),
      'description': _asString(json['description']),
    });
  }

  static String _parseCategory(dynamic value) {
    if (value is Map<String, dynamic>) {
      return _asString(value['name']);
    }

    return _asString(value);
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final normalized = value.trim();
      return int.tryParse(normalized) ?? double.tryParse(normalized)?.toInt() ?? 0;
    }
    return 0;
  }
}
