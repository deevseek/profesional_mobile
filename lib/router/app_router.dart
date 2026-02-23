import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/core/error/global_error_handler.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/pages/pos_placeholder_page.dart';
import 'package:profesionalservis_mobile/features/tenant/presentation/pages/tenant_loading_page.dart';
import 'package:profesionalservis_mobile/features/tenant/presentation/pages/tenant_selection_page.dart';
import 'package:profesionalservis_mobile/tenant/tenant_guard.dart';
import 'package:profesionalservis_mobile/tenant/tenant_state_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<int>(0);

  ref
    ..onDispose(refreshListenable.dispose)
    ..listen<TenantState>(tenantStateProvider, (_, __) {
      refreshListenable.value++;
    });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/tenant-loading',
    refreshListenable: refreshListenable,
    redirect: (context, state) => TenantGuard.redirect(ref, state),
    routes: [
      GoRoute(
        path: '/tenant-loading',
        builder: (context, state) => const TenantLoadingPage(),
      ),
      GoRoute(
        path: '/tenant',
        builder: (context, state) => const TenantSelectionPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const PosPlaceholderPage(),
      ),
    ],
  );
});
