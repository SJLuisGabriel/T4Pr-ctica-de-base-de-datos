import 'package:flutter/material.dart';

class Themesettings {
  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.deepPurple,
      appBarTheme: const AppBarTheme(
        color: Colors.deepPurple,
        elevation: 4,
      ),
      scaffoldBackgroundColor: Colors.black,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.grey, fontSize: 14),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.deepPurple, // Color de fondo de los botones
        textTheme: ButtonTextTheme.primary, // Color del texto del botón
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple, // Color del texto
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Bordes redondeados
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.deepPurple, // Color del texto
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[850], // Color de fondo del campo de texto
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Bordes redondeados
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        hintStyle: const TextStyle(
            color: Colors.grey), // Estilo del texto de sugerencia
      ),
      iconTheme: const IconThemeData(
        color: Colors.white, // Color de los íconos
      ),
      cardTheme: CardTheme(
        color: Colors.grey[850], // Color de fondo de las tarjetas
        elevation: 4, // Sombra de las tarjetas
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10), // Bordes redondeados en las tarjetas
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:
            Colors.grey, // Color de fondo de la barra de navegación
        selectedItemColor: Colors.deepPurple, // Color del elemento seleccionado
        unselectedItemColor: Colors.white, // Color del elemento no seleccionado
      ),
    );
  }
}
