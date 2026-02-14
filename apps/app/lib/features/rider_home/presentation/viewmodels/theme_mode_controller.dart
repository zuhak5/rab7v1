import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeModeControllerProvider =
    AsyncNotifierProvider<AppThemeModeController, ThemeMode>(
      AppThemeModeController.new,
    );

class AppThemeModeController extends AsyncNotifier<ThemeMode> {
  static const _storageKey = 'theme';

  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == ThemeMode.dark.name) {
      return ThemeMode.dark;
    }
    if (raw == ThemeMode.light.name) {
      return ThemeMode.light;
    }
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = AsyncValue<ThemeMode>.data(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, mode.name);
  }

  Future<void> toggleDark() async {
    final current = state.valueOrNull ?? ThemeMode.system;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }
}
