import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/dashboard_summary_model.dart';
import 'package:profesionalservis_mobile/features/pos/data/repositories/dashboard_repository.dart';

final dashboardSummaryProvider =
    FutureProvider.autoDispose<DashboardSummaryModel>((ref) async {
      final repository = ref.watch(dashboardRepositoryProvider);
      return repository.getSummary();
    });
