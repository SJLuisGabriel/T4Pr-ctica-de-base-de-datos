import 'package:flutter/material.dart';
import 'package:t4bd/screen/home_screen.dart';
import 'package:t4bd/screen/login_screen.dart';
import 'package:t4bd/screen/pendientes_screen.dart';
import 'package:t4bd/screen/perfil_screen.dart';
import 'package:t4bd/screen/recuperar_password_screen.dart';
import 'package:t4bd/screen/registro_screen.dart';
import 'package:t4bd/screen/registro_usuario_screen.dart';
import 'package:t4bd/screen/ventas_screen.dart';
import 'package:t4bd/screen/welcom_screen.dart';
import 'package:t4bd/settings/theme_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado correctamente');
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Programación Móviles',
      theme: Themesettings.darkTheme(),
      home: const LoginScreen(),
      routes: {
        // Screen De Bienvenida De La App
        '/welcome': (context) => const WelcomScreen(),
        // Screen Para Ver Las Ventas Pendientes Por Cumplir
        '/pendientes': (context) => const PendientesScreen(),
        // Inicio De La App, aqui ponemos el menu y todo lo que lleva a las demas cosas
        '/home': (context) => const HomeScreen(),
        // Screen Para Registrar Ventas
        '/register': (context) => const RegistroScreen(),
        // Screen Para La Lista De Las Ventas
        '/ventas': (context) => const VentasScreen(),

        // Proyecto Final
        // Login
        '/login': (context) => const LoginScreen(),
        // Register User
        '/registro': (context) => const RegistroUsuarioScreen(),
        // Recuperar password
        '/recuperarpassword': (context) => const RecuperarPasswordScreen(),
        // Perfil
        '/perfil': (context) => const PerfilScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
