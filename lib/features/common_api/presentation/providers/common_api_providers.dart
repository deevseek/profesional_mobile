import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/common_api/data/models/api_resource_model.dart';
import 'package:profesionalservis_mobile/features/common_api/data/repositories/generic_crud_repository.dart';
import 'package:profesionalservis_mobile/shared/models/paginated_response.dart';

class ApiListQuery {
  const ApiListQuery({required this.endpoint, this.search, this.page = 1, this.perPage = 20, this.filters = const <String, dynamic>{}});

  final String endpoint;
  final String? search;
  final int page;
  final int perPage;
  final Map<String, dynamic> filters;

  @override
  bool operator ==(Object other) =>
      other is ApiListQuery && endpoint == other.endpoint && search == other.search && page == other.page && perPage == other.perPage && filters.toString() == other.filters.toString();

  @override
  int get hashCode => Object.hash(endpoint, search, page, perPage, filters.toString());
}

final apiResourceListProvider = FutureProvider.family<PaginatedResponse<ApiResourceModel>, ApiListQuery>((ref, query) async {
  return ref.watch(genericCrudRepositoryProvider).list(
    query.endpoint,
    query: {
      'page': query.page,
      'per_page': query.perPage,
      if (query.search != null && query.search!.trim().isNotEmpty) 'search': query.search!.trim(),
      ...query.filters,
    },
  );
});

final apiResourceDetailProvider = FutureProvider.family<ApiResourceModel, ({String endpoint, String id})>((ref, args) async {
  return ref.watch(genericCrudRepositoryProvider).detail(args.endpoint, args.id);
});
