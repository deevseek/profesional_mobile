import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/tenant/tenant_state_provider.dart';

class TenantGuard {
  const TenantGuard._();

  static String? redirect(WidgetRef ref, GoRouterState state) {
    final tenantState = ref.read(tenantStateProvider);
    final location = state.uri.path;

    if (tenantState.isBootstrapping) {
      if (location != '/tenant-loading') {
        return '/tenant-loading';
      }
      return null;
    }

    if (!tenantState.hasTenant) {
      if (location != '/tenant') {
        return '/tenant';
      }
      return null;
    }

    if (location == '/tenant' || location == '/tenant-loading') {
      return '/login';
    }

    return null;
  }
}
