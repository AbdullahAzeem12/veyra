import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemePreference { system, light, dark }

/// Controls appearance (light/dark/system) and premium-depth styling independently.
/// Persists choices across restarts via SharedPreferences.
class ThemeController extends ChangeNotifier {
  ThemePreference _themePreference = ThemePreference.system;
  bool _premiumDepthEnabled = true;

  ThemePreference get themePreference => _themePreference;
  bool get premiumDepthEnabled => _premiumDepthEnabled;

  ThemeMode get themeMode {
    switch (_themePreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('themePreference') ?? 'system';
    _themePreference = ThemePreference.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => ThemePreference.system,
    );
    _premiumDepthEnabled = prefs.getBool('premiumDepthEnabled') ?? true;
    notifyListeners();
  }

  Future<void> setThemePreference(ThemePreference pref) async {
    _themePreference = pref;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themePreference', pref.name);
  }

  Future<void> togglePremiumDepth() async {
    _premiumDepthEnabled = !_premiumDepthEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premiumDepthEnabled', _premiumDepthEnabled);
  }

  Future<void> setPremiumDepth(bool value) async {
    _premiumDepthEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premiumDepthEnabled', value);
  }
}
