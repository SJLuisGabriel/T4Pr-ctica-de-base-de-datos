import 'package:flutter/material.dart';
import 'package:t4bd/screen/welcom_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo de texto para el usuario
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo de texto para la contraseña
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botón para iniciar sesión
                  ElevatedButton(
                    onPressed: () {
                      final username = _usernameController.text;
                      final password = _passwordController.text;
                      print('Usuario: $username, Contraseña: $password');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 8),
                  // Enlace para recuperar contraseña
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/recuperarpassword');
                      print('Recuperar contraseña presionado');
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ],
              ),
            ),
          ),
          // Botón para crear cuenta en la esquina superior derecha
          Positioned(
            top: 40,
            right: 16,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registro');
              },
              child: const Text(
                'Crear cuenta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
