import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/tenant/tenant_state_provider.dart';

class TenantGuard {
  const TenantGuard._();

  static String? redirect(Ref ref, GoRouterState state) {
    final tenantState = ref.read(tenantStateProvider);
    final authState = ref.read(authStateProvider);
    final location = state.uri.path;

    if (tenantState.isBootstrapping || authState.isBootstrapping) {
      if (location != '/splash') {
        return '/splash';
      }
      return null;
    }

    if (!tenantState.hasTenant) {
      if (location != '/tenant' && location != '/splash') {
        return '/tenant';
      }
      return null;
    }

    if (!authState.isAuthenticated) {
      if (location != '/login' && location != '/splash') {
        return '/login';
      }
      return null;
    }

    if (location == '/login' || location == '/tenant') {
      return '/home';
    }

    return null;
  }
}
