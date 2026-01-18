import '../domain/category_model.dart';
import '../domain/category_repository.dart';
import 'category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({CategoryRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CategoryRemoteDataSource();

  final CategoryRemoteDataSource _remoteDataSource;

  @override
  Future<CategoryPage> getCategories({
    String? search,
    int page = 1,
    int? perPage,
  }) {
    return _remoteDataSource.fetchCategories(
      search: search,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<Category> getCategory(String id) {
    return _remoteDataSource.fetchCategory(id);
  }

  @override
  Future<Category> createCategory(Category category) {
    return _remoteDataSource.createCategory(category);
  }

  @override
  Future<Category> updateCategory(String id, Category category) {
    return _remoteDataSource.updateCategory(id, category);
  }

  @override
  Future<void> deleteCategory(String id) {
    return _remoteDataSource.deleteCategory(id);
  }
}
