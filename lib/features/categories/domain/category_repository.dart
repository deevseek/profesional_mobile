import 'category_model.dart';

abstract class CategoryRepository {
  Future<CategoryPage> getCategories({
    String? search,
    int page = 1,
    int? perPage,
  });

  Future<Category> getCategory(String id);

  Future<Category> createCategory(Category category);

  Future<Category> updateCategory(String id, Category category);

  Future<void> deleteCategory(String id);
}
