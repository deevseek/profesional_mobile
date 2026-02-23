import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/core/error/global_error_handler.dart';
import 'package:profesionalservis_mobile/features/pos/presentation/pages/pos_placeholder_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PosPlaceholderPage(),
      ),
    ],
  );
});
