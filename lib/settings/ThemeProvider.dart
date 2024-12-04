import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _fontFamily = 'Roboto';

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  void setFontFamily(String fontFamily) {
    _fontFamily = fontFamily;
    notifyListeners();
  }

  ThemeData get currentTheme {
    return ThemeData(
      fontFamily: _fontFamily, // Cambiar la fuente globalmente
      brightness:
          _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
    );
  }
}
