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
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Agregar la imagen de fondo
                Positioned.fill(
                  child: Image.asset(
                    'assets/fondo.jpg', // Ruta de la imagen
                    fit: BoxFit.cover, // Ajusta la imagen al tamaño disponible
                  ),
                ),
                const SizedBox(height: 800),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 70.0, left: 16.0, right: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Imagen
                        Image.asset(
                          'assets/images.jpg',
                          height: 250,
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 30),

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
                              MaterialPageRoute(
                                  builder: (context) => const WelcomScreen()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text('Iniciar sesión'),
                          style: ElevatedButton.styleFrom(
                            minimumSize:
                                const Size(double.infinity, 50), // Igual tamaño
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.normal), // Mismo TextStyle
                            backgroundColor: Colors.blue, // Color de fondo
                            foregroundColor: Colors.white, // Color del texto
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),

                        const Text(
                          "'O'",
                          style: TextStyle(
                            fontSize: 27, // Tamaño de la fuente
                            fontWeight: FontWeight.bold, // Peso de la fuente
                            letterSpacing: 2,
                            // Estilo de la fuente (cursiva)
                          ),
                        ),
                        const SizedBox(height: 13),

                        // Botón para iniciar sesión con Google
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.golf_course),
                          label: const Text('Iniciar sesión con Google'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal),
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Botón para iniciar sesión con Facebook
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.facebook),
                          label: const Text('Iniciar sesión con Facebook'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            textStyle: const TextStyle(fontSize: 16),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Botón para iniciar sesión con GitHub
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.code),
                          label: const Text('Iniciar sesión con GitHub'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            textStyle: const TextStyle(fontSize: 16),
                            backgroundColor:
                                const Color.fromARGB(255, 65, 55, 55),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
                Positioned(
                  top: 40,
                  right: 16,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registro');
                    },
                    child: const Text(
                      'Crear cuenta',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
