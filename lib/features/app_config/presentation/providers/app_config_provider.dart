import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/app_config/data/models/app_config_model.dart';
import 'package:profesionalservis_mobile/features/app_config/data/repositories/app_config_repository.dart';

final appConfigProvider = FutureProvider<AppConfigModel>((ref) async {
  return ref.watch(appConfigRepositoryProvider).getAppConfig();
});
