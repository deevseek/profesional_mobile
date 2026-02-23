// coverage:ignore-file
// GENERATED CODE - MANUALLY WRITTEN (flutter unavailable in environment)

part of 'service_item_model.dart';

mixin _$ServiceItemModel {
  String get id => throw UnimplementedError();
  String get serviceId => throw UnimplementedError();
  String get productId => throw UnimplementedError();
  String get productName => throw UnimplementedError();
  int get qty => throw UnimplementedError();
  int get price => throw UnimplementedError();
  int get subtotal => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

class _ServiceItemModel extends ServiceItemModel {
  const _ServiceItemModel({
    this.id = '',
    this.serviceId = '',
    this.productId = '',
    this.productName = '',
    this.qty = 0,
    this.price = 0,
    this.subtotal = 0,
  }) : super._();

  @override
  final String id;
  @override
  final String serviceId;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final int qty;
  @override
  final int price;
  @override
  final int subtotal;

  @override
  Map<String, dynamic> toJson() => _$ServiceItemModelToJson(this);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _ServiceItemModel &&
            other.id == id &&
            other.serviceId == serviceId &&
            other.productId == productId &&
            other.productName == productName &&
            other.qty == qty &&
            other.price == price &&
            other.subtotal == subtotal);
  }

  @override
  int get hashCode => Object.hash(id, serviceId, productId, productName, qty, price, subtotal);
}
