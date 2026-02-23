import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class GlobalErrorHandler {
  static void initialize() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      handleFlutterError(details);
    };

    ErrorWidget.builder = (details) => Material(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                kReleaseMode
                    ? 'Terjadi kesalahan. Mohon coba kembali.'
                    : details.exceptionAsString(),
                textAlign: TextAlign.center,
              ),
            ),
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
  }
}
