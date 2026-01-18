import '../domain/product_model.dart';
import '../domain/product_repository.dart';
import 'product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({ProductRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProductRemoteDataSource();

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<ProductPage> getProducts({
    String? search,
    String? categoryId,
    int page = 1,
    int perPage = 15,
  }) {
    return _remoteDataSource.fetchProducts(
      search: search,
      categoryId: categoryId,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<Product> getProduct(String id) {
    return _remoteDataSource.fetchProduct(id);
  }

  @override
  Future<Product> createProduct(Product product) {
    return _remoteDataSource.createProduct(product);
  }

  @override
  Future<Product> updateProduct(String id, Product product) {
    return _remoteDataSource.updateProduct(id, product);
  }

  @override
  Future<void> deleteProduct(String id) {
    return _remoteDataSource.deleteProduct(id);
  }
}
