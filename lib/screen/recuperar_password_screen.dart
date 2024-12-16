import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  State<RecuperarPasswordScreen> createState() =>
      _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarRecuperacion() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      try {
        // Enviar enlace de recuperación de contraseña
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Correo enviado con instrucciones para restablecer tu contraseña.",
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Opcional: Regresar al inicio de sesión
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = "No existe una cuenta registrada con este correo.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "El correo ingresado no es válido.";
        } else {
          errorMessage = "Ocurrió un error: ${e.message}";
        }

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        // Manejo de errores genéricos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ocurrió un error inesperado: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Registro de contraseña"),
          backgroundColor: Colors.teal[800],
        ),
        body: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 600;
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/fondo.jpg', // Ruta de la imagen
                    fit: BoxFit.cover, // Ajusta la imagen al tamaño disponible
                  ),
                ),
                const SizedBox(height: 800),
                Card(
                  color: Colors.teal[200],
                  elevation: 5,
                  margin: EdgeInsets.symmetric(
                    horizontal: isDesktop ? constraints.maxWidth * 0.2 : 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Recuperar tu Contraseña",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Ingresa tu correo electrónico registrado para recibir un enlace de recuperación.",
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: "Correo Electrónico",
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Este campo es obligatorio";
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return "Ingrese un correo válido.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _enviarRecuperacion,
                            child: const Text("Enviar Correo"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ));
  }
}
