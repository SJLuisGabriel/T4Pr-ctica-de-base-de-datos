import 'package:flutter/material.dart';
import 'package:t4bd/screen/home_screen.dart';
import 'package:t4bd/screen/registro_screen.dart';
import 'package:t4bd/screen/welcom_screen.dart';
import 'package:t4bd/settings/theme_settings.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Programación Móviles',
      theme: Themesettings.darkTheme(),
      home: const WelcomScreen(),
      routes: {
        // Screen De Bienvenida De La App
        '/welcome': (context) => const WelcomScreen(),
        // Inicio De La App, aqui ponemos el menu y todo lo que lleva a las demas cosas
        '/home': (context) => const HomeScreen(),
        // Screen Para Registrar Ventas
        '/register': (context) => const RegistroScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
