import 'package:flutter/material.dart';

class ModoOscuro {
  static ThemeData get() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      hintColor: Colors.purpleAccent,
      scaffoldBackgroundColor: Colors.black87,
      appBarTheme: const AppBarTheme(
        color: Colors.deepPurple,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        toolbarTextStyle: TextStyle(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            color: Colors.white70, fontSize: 24, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white60, fontSize: 14),
        bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.deepPurple,
        shape: StadiumBorder(),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.deepPurple,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      cardTheme: const CardTheme(
        color: Colors.black45,
        elevation: 6,
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.black38,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurpleAccent),
        ),
        hintStyle: TextStyle(color: Colors.white60),
        labelStyle: TextStyle(color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white30,
        space: 1,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurple,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.white60,
        elevation: 10,
      ),
    );
  }
}

class ModoLuz {
  static ThemeData get() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      hintColor: Colors.lightBlueAccent,
      scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBarTheme: const AppBarTheme(
        color: Colors.blue,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        toolbarTextStyle: TextStyle(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            color: Colors.black87, fontSize: 24, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
        bodySmall: TextStyle(color: Colors.black45, fontSize: 12),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.blue,
        shape: StadiumBorder(),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 6,
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        hintStyle: TextStyle(color: Colors.black38),
        labelStyle: TextStyle(color: Colors.black),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.black38,
        space: 1,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        elevation: 10,
      ),
    );
  }
}
