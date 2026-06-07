import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/finance/data/models/finance_model.dart';
import 'package:profesionalservis_mobile/features/finance/data/repositories/finance_repository.dart';

final financeListProvider = FutureProvider.family<FinanceListResponse, String?>((ref, type) => ref.watch(financeRepositoryProvider).getFinances(type: type));
final financeSummaryProvider = FutureProvider<FinanceSummaryModel>((ref) async => (await ref.watch(financeRepositoryProvider).getFinances()).summary);
