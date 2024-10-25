import 'package:flutter/material.dart';
import 'package:t4bd/screen/home_screen.dart';
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
        '/welcome': (context) => const WelcomScreen(),
        '/home': (context) => const HomeScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
