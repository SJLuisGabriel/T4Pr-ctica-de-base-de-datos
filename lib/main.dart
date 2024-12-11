import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:t4bd/api/firebase_api.dart';
import 'package:t4bd/screen/actualizarPerfil_screen.dart';
import 'package:t4bd/screen/alta_producto.dart';
import 'package:t4bd/screen/const.dart';
import 'package:t4bd/screen/home_screen.dart';
import 'package:t4bd/screen/login_screen.dart';
import 'package:t4bd/screen/maps_screen.dart';
import 'package:t4bd/screen/onboarding_screen.dart';
import 'package:t4bd/screen/pendientes_screen.dart';
import 'package:t4bd/screen/perfil_screen.dart';
import 'package:t4bd/screen/recuperar_password_screen.dart';
import 'package:t4bd/screen/registro_screen.dart';
import 'package:t4bd/screen/registro_usuario_screen.dart';
import 'package:t4bd/screen/suscripciones_screen.dart';
import 'package:t4bd/screen/themas_screen.dart';
import 'package:t4bd/screen/ventas_screen.dart';
import 'package:t4bd/screen/welcom_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:t4bd/settings/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:t4bd/settings/ThemeProvider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Notifications
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();

  // await _setup();
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado correctamente');
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }

  // Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://hymamtgnkyoalwimilll.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh5bWFtdGdua3lvYWx3aW1pbGxsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIxMzkyMDAsImV4cCI6MjA0NzcxNTIwMH0.8FJGgxMnY9gdUMR3ty3mYIfWuvjUsaoxk8B5g-BHnRE',
  );

  // Ejecutar la aplicación
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Programación Móviles',
      navigatorKey: navigatorKey,
      theme: themeProvider.themeData, // Usamos el tema del provider
      home: const LoginScreen(),
      routes: {
        '/welcome': (context) => const WelcomScreen(),
        '/pendientes': (context) => const PendientesScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegistroScreen(),
        '/ventas': (context) => const VentasScreen(),
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegistroUsuarioScreen(),
        '/recuperarpassword': (context) => const RecuperarPasswordScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/actualizarperfil': (context) => const ActualizarperfilScreen(),
        '/temas': (context) => const ThemasScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/maps': (context) => const MapsScreen(),
        '/suscripcion': (context) => const SuscripcionesScreen(),
        '/alta': (context) => const AltaProducto(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
