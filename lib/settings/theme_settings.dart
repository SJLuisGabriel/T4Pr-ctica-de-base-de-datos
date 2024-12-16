import 'package:flutter/material.dart';

class ThemeSettings {
  static ThemeData modoOscuro() {
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      primaryColor: const Color.fromARGB(255, 0, 105, 92), // Verde oscuro
      hintColor: const Color.fromARGB(255, 0, 184, 148), // Verde claro
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        color: Color.fromARGB(255, 0, 105, 92),
        elevation: 2,
        iconTheme: IconThemeData(color: Color(0xFF80CBC4)),
        actionsIconTheme: IconThemeData(color: Color(0xFF26A69A)),
        toolbarTextStyle: TextStyle(color: Color(0xFFA5D6A7)),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        displayMedium: TextStyle(
          color: Colors.white70,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white60, fontSize: 14),
        bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              const Color.fromARGB(255, 0, 184, 148), // Texto verde claro
          side: const BorderSide(
            color: Color.fromARGB(255, 0, 184, 148), // Borde verde claro
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 0, 105, 92),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color.fromARGB(255, 0, 105, 92),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 184, 148)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 184, 148)),
          borderRadius: BorderRadius.circular(12),
        ),
        hintStyle: const TextStyle(color: Colors.white60),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1D1D1D),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: Color.fromARGB(255, 0, 184, 148),
        unselectedItemColor: Colors.white54,
        elevation: 8,
      ),
    );
  }

  static ThemeData modoLuz() {
    return ThemeData.light().copyWith(
      brightness: Brightness.light,
      primaryColor: const Color.fromARGB(255, 0, 105, 92), // Verde oscuro
      hintColor: const Color.fromARGB(255, 0, 77, 64), // Verde profundo
      scaffoldBackgroundColor: const Color(0xFFE0F2F1), // Fondo claro
      appBarTheme: const AppBarTheme(
        color: Color.fromARGB(255, 0, 105, 92),
        elevation: 2,
        iconTheme: IconThemeData(color: Color(0xFF004D40)),
        actionsIconTheme: IconThemeData(color: Color(0xFF00796B)),
        toolbarTextStyle: TextStyle(color: Color(0xFF004D40)),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF004D40),
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF004D40),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Color(0xFF004D40), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF00796B), fontSize: 14),
        bodySmall: TextStyle(color: Color(0xFF004D40), fontSize: 12),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              const Color.fromARGB(255, 0, 105, 92), // Texto verde oscuro
          side: const BorderSide(
            color: Color.fromARGB(255, 0, 105, 92), // Borde verde oscuro
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 0, 105, 92),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color.fromARGB(255, 0, 105, 92),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE0F2F1),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 77, 64)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 105, 92)),
          borderRadius: BorderRadius.circular(12),
        ),
        hintStyle: const TextStyle(color: Color(0xFF004D40)),
        labelStyle: const TextStyle(color: Color(0xFF004D40)),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFFFFFFFF),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFE0F2F1),
        selectedItemColor: Color.fromARGB(255, 0, 105, 92),
        unselectedItemColor: Color(0xFF004D40),
        elevation: 8,
      ),
    );
  }
}
