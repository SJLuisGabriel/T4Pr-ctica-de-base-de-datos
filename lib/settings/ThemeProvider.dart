import 'package:flutter/material.dart';
import 'theme_settings.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _fontFamily = 'Roboto'; // Fuente por defecto

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
    if (_themeMode == ThemeMode.dark) {
      final darkTheme = ModoOscuro.get();
      return darkTheme.copyWith(
        textTheme: darkTheme.textTheme.apply(fontFamily: _fontFamily),
      );
    } else {
      final lightTheme = ModoLuz.get();
      return lightTheme.copyWith(
        textTheme: lightTheme.textTheme.apply(fontFamily: _fontFamily),
      );
    }
  }
}
