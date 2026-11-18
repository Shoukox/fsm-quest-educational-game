import 'package:bachelor/core/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemePreference {
  light('light', Brightness.light),
  dark('dark', Brightness.dark);

  const AppThemePreference(this.storageValue, this.brightness);

  final String storageValue;
  final Brightness brightness;

  static AppThemePreference fromStorageValue(String value) {
    return AppThemePreference.values.firstWhere(
      (mode) => mode.storageValue == value,
      orElse: () => AppThemePreference.dark,
    );
  }
}

final appThemePreferenceProvider =
    NotifierProvider<AppThemePreferenceController, AppThemePreference>(
      AppThemePreferenceController.new,
    );

/// Stellt zunächst das dunkle Design bereit und lädt die gespeicherte Auswahl nach.
class AppThemePreferenceController extends Notifier<AppThemePreference> {
  static const _themeKey = 'app_theme';

  @override
  AppThemePreference build() {
    Future.microtask(_loadTheme);
    return AppThemePreference.dark;
  }

  Future<void> setTheme(AppThemePreference theme) async {
    state = theme;
    try {
      await LocalStorageService().setString(_themeKey, theme.storageValue);
    } catch (_) {
      // In Tests oder beim frühen App-Start kann die Datenbank noch fehlen.
    }
  }

  Future<void> _loadTheme() async {
    try {
      final value = await LocalStorageService().getString(_themeKey);
      if (value == null) return;
      state = AppThemePreference.fromStorageValue(value);
    } catch (_) {
      state = AppThemePreference.dark;
    }
  }
}
