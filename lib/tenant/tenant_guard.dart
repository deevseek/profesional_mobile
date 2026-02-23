import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/tenant/tenant_state_provider.dart';

class TenantGuard {
  const TenantGuard._();

  static String? redirect(WidgetRef ref, GoRouterState state) {
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
      if (location != '/tenant') {
        return '/tenant';
      }
      return null;
    }

    if (!authState.isAuthenticated) {
      if (location != '/login') {
        return '/login';
      }
      return null;
    }

    if (location == '/login' || location == '/tenant' || location == '/splash') {
      return '/pos';
    }

    return null;
  }
}
