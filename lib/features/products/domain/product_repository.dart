import 'product_model.dart';

abstract class ProductRepository {
  Future<ProductPage> getProducts({
    String? search,
    String? categoryId,
    int page = 1,
    int perPage = 15,
  });

  Future<Product> getProduct(String id);

  Future<Product> createProduct(Product product);

  Future<Product> updateProduct(String id, Product product);

  Future<void> deleteProduct(String id);
}
