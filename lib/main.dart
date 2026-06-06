import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/core/error/global_error_handler.dart';
import 'package:profesionalservis_mobile/core/loading/loading_overlay.dart';
import 'package:profesionalservis_mobile/router/app_router.dart';
import 'package:profesionalservis_mobile/theme/app_theme.dart';
import 'package:profesionalservis_mobile/theme/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalErrorHandler.initialize();
  runZonedGuarded(
    () => runApp(const ProviderScope(child: ProfesionalServisApp())),
    GlobalErrorHandler.handleZoneError,
  );
}

class ProfesionalServisApp extends ConsumerWidget {
  const ProfesionalServisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Profesional Servis',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return LoadingOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
