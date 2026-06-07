import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/core/error/global_error_handler.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/features/showcase/presentation/pages/app_shell_page.dart';
import 'package:profesionalservis_mobile/features/splash/presentation/pages/splash_page.dart';
import 'package:profesionalservis_mobile/features/tenant/presentation/pages/tenant_selection_page.dart';
import 'package:profesionalservis_mobile/tenant/tenant_guard.dart';
import 'package:profesionalservis_mobile/tenant/tenant_state_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<int>(0);

  ref
    ..onDispose(refreshListenable.dispose)
    ..listen<TenantState>(tenantStateProvider, (_, __) {
      refreshListenable.value++;
    })
    ..listen<AuthState>(authStateProvider, (_, __) {
      refreshListenable.value++;
    });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) => TenantGuard.redirect(ref, state),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
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
        path: '/home',
        builder: (context, state) => const AppShellPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AppShellPage(),
      ),
      GoRoute(
        path: '/service',
        builder: (context, state) => const AppShellPage(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const AppShellPage(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const AppShellPage(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const AppShellPage(),
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const AppShellPage(),
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const AppShellPage(),
      ),
      GoRoute(
        path: '/more',
        builder: (context, state) => const AppShellPage(),
      ),
    ],
  );
});
