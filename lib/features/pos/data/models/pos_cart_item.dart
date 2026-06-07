import 'package:profesionalservis_mobile/features/product/data/models/product_model.dart';

class PosCartItem {
  const PosCartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0,
  });

  final ProductModel product;
  final int quantity;
  final int discount;

  int get lineBaseTotal => product.price * quantity;
  int get hpp => 0;
  int get lineTotal => (lineBaseTotal - discount).clamp(0, lineBaseTotal).toInt();

  PosCartItem copyWith({
    ProductModel? product,
    int? quantity,
    int? discount,
  }) {
    return PosCartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }
}
