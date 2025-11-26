import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService _instance = ThemeService._();
  factory ThemeService() => _instance;

  static const _kDarkModeKey = 'safepath_dark_mode';

  Future<bool> isDarkMode() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kDarkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kDarkModeKey, isDark);
  }

  Future<void> toggleDarkMode() async {
    final current = await isDarkMode();
    await setDarkMode(!current);
  }
}
