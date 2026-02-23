// coverage:ignore-file
// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'product_model.dart';

mixin _$ProductModel {
  String get id => throw UnimplementedError();
  String get name => throw UnimplementedError();
  String get sku => throw UnimplementedError();
  String get category => throw UnimplementedError();
  int get stock => throw UnimplementedError();
  int get price => throw UnimplementedError();
  String get description => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

class _ProductModel extends ProductModel {
  const _ProductModel({
    this.id = '',
    this.name = '',
    this.sku = '',
    this.category = '',
    this.stock = 0,
    this.price = 0,
    this.description = '',
  }) : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String sku;
  @override
  final String category;
  @override
  final int stock;
  @override
  final int price;
  @override
  final String description;

  @override
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _ProductModel &&
            other.id == id &&
            other.name == name &&
            other.sku == sku &&
            other.category == category &&
            other.stock == stock &&
            other.price == price &&
            other.description == description);
  }

  @override
  int get hashCode => Object.hash(id, name, sku, category, stock, price, description);
}
