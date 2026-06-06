import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:profesionalservis_mobile/shared/widgets/app_error_view.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class GlobalErrorHandler {
  static void initialize() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      handleFlutterError(details);
      showErrorSnackbar(
        kReleaseMode
            ? 'Terjadi kesalahan. Mohon coba kembali.'
            : details.exceptionAsString(),
      );
    };

    ErrorWidget.builder = (details) => Material(
          color: Colors.white,
          child: AppErrorView(
            message: details.exceptionAsString(),
            onReload: () {},
          ),
        );
  }

  static void handleFlutterError(FlutterErrorDetails details) {
    log('FlutterError: ${details.exceptionAsString()}',
        stackTrace: details.stack,
        name: 'GlobalErrorHandler');
  }

  static void handleZoneError(Object error, StackTrace stackTrace) {
    log('ZoneError: $error',
        stackTrace: stackTrace, name: 'GlobalErrorHandler');
    showErrorSnackbar('Aplikasi mengalami gangguan. Coba lagi beberapa saat.');
  }

  static void showErrorSnackbar(String message, {SnackBarAction? action}) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: action,
          duration: const Duration(seconds: 4),
        ),
      );
  }
}
