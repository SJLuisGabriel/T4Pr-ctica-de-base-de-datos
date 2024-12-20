import 'package:flutter/material.dart';
import 'theme_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String keyTheme = 'selectedTheme';
  static const String keyFont = 'selectedFont';
  static const String keyCustomColor = 'customColor';

  String _currentFont = 'Roboto';
  String get currentFont => _currentFont;

  String _currentTheme = 'light';
  String get currentTheme => _currentTheme;

  ThemeData _themeData = ThemeSettings.modoLuz();
  ThemeData get themeData => _themeData;

  Color _customColor = Colors.blue;
  Color get customColor => _customColor;

  bool _obscureText = true;

  bool get obscureText => _obscureText;

  void toggleVisibility() {
    _obscureText = !obscureText;
    notifyListeners();
  }

  ThemeNotifier() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _currentTheme = prefs.getString(keyTheme) ?? 'light';
    _currentFont = prefs.getString(keyFont) ?? 'Roboto';
    _customColor = Color(prefs.getInt(keyCustomColor) ?? Colors.blue.value);
    _applyTheme(_currentTheme);
  }

  Future<void> setTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    _currentTheme = themeName;
    await prefs.setString(keyTheme, themeName);
    _applyTheme(themeName);
  }

  Future<void> setCustomColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    _customColor = color;
    await prefs.setInt(keyCustomColor, color.value);
    if (_currentTheme == 'custom') {
      _applyTheme('custom');
    }
  }

  void _applyTheme(String themeName) {
    if (themeName == 'dark') {
      _themeData = ThemeSettings.modoOscuro();
    } else {
      _themeData = ThemeSettings.modoLuz();
    }
    // else if (themeName == 'custom') {
    //   _themeData = ThemeSettings.customTheme();
    // }

    // Aplicar la fuente actual al tema
    _updateFont();
    notifyListeners();
  }

  Future<void> setFont(String font) async {
    _currentFont = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyFont, font);
    _updateFont();
  }

  void _updateFont() {
    _themeData = _themeData.copyWith(
      textTheme: _themeData.textTheme.copyWith(
        bodySmall: TextStyle(
            fontFamily: _currentFont,
            color: _themeData.textTheme.bodySmall?.color),
        bodyMedium: TextStyle(
            fontFamily: _currentFont,
            color: _themeData.textTheme.bodyMedium?.color),
        bodyLarge: TextStyle(
            fontFamily: _currentFont,
            color: _themeData.textTheme.bodyLarge?.color),
        titleSmall: TextStyle(
            fontFamily: _currentFont,
            color: _themeData.textTheme.titleSmall?.color),
        titleMedium: TextStyle(
            fontFamily: _currentFont,
            color: _themeData.textTheme.titleMedium?.color),
        titleLarge: TextStyle(
            fontFamily: _currentFont,
            color: _themeData.textTheme.titleLarge?.color),
        labelSmall: TextStyle(
            fontFamily: _currentFont,
            color: _themeData.textTheme.labelSmall?.color),
        labelMedium: TextStyle(
            fontFamily: _currentFont,
            color: _themeData.textTheme.labelMedium?.color),
        labelLarge: TextStyle(
            fontFamily: _currentFont,
            color: _themeData.textTheme.labelLarge?.color),
      ),
    );
    notifyListeners();
  }
}
