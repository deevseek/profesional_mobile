import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/storage/secure_storage_service.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(secureStorageServiceProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(ThemeMode.light) {
    _restore();
  }

  static const _key = 'theme_mode';
  final SecureStorageService _storage;

  Future<void> _restore() async {
    final value = await _storage.readValue(_key);
    state = switch (value) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storage.writeValue(_key, mode.name);
  }

  Future<void> toggleDarkMode(bool enabled) => setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
}
