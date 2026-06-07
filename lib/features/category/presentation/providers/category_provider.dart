import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/category/data/models/category_model.dart';
import 'package:profesionalservis_mobile/features/category/data/repositories/category_repository.dart';
import 'package:profesionalservis_mobile/shared/models/paginated_response.dart';

final categoryListProvider = FutureProvider.family<PaginatedResponse<CategoryModel>, String?>((ref, search) => ref.watch(categoryRepositoryProvider).getCategories(search: search));
