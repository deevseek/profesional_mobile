import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/supplier/data/models/supplier_model.dart';
import 'package:profesionalservis_mobile/features/supplier/data/repositories/supplier_repository.dart';
import 'package:profesionalservis_mobile/shared/models/paginated_response.dart';

final supplierListProvider = FutureProvider.family<PaginatedResponse<SupplierModel>, String?>((ref, search) => ref.watch(supplierRepositoryProvider).getSuppliers(search: search));
