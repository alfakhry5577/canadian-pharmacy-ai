import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_endpoints.dart';
import 'core_providers.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this.ref) : super(ThemeMode.system) {
    _load();
  }
  final Ref ref;

  void _load() {
    final stored = ref.read(sharedPreferencesProvider).getString(StorageKeys.themeMode);
    state = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(StorageKeys.themeMode, mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier(ref));

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this.ref) : super(const Locale('ar')) {
    _load();
  }
  final Ref ref;

  void _load() {
    final stored = ref.read(sharedPreferencesProvider).getString(StorageKeys.localeCode);
    state = Locale(stored ?? 'ar');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(sharedPreferencesProvider).setString(StorageKeys.localeCode, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier(ref));
