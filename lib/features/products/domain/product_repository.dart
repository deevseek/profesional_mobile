import 'product_model.dart';

abstract class ProductRepository {
  Future<ProductPage> getProducts({
    String? search,
    int page = 1,
  });

  Future<Product> getProduct(String id);

  Future<Product> createProduct(Product product);

  Future<Product> updateProduct(String id, Product product);

  Future<void> deleteProduct(String id);
}
