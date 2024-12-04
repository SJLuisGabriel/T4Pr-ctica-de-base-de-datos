import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Timer? _timer;
  int _countdown = 30;
  bool _showResendButton = false;
  bool _isSendingEmail = false;
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 30;
      _showResendButton = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown == 0) {
        _timer?.cancel();
        setState(() {
          _showResendButton = true;
        });
      }
    });
  }

  // Función para registrar al usuario en Firebase
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Crear usuario en Firebase
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Enviar correo de verificación
        await userCredential.user?.sendEmailVerification();

        // Marcar como correo enviado
        setState(() {
          _isEmailSent = true;
        });

        // Mostrar mensaje de que se ha enviado el correo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado un correo de verificación.'),
          ),
        );

        // Iniciar el conteo para reenviar el correo
        _startCountdown();
      } catch (e) {
        // Mostrar errores en caso de que ocurran
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Función para reenviar el correo de verificación
  Future<void> _resendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        setState(() {
          _isSendingEmail = true;
        });

        await user.sendEmailVerification();
        setState(() {
          _isSendingEmail = false;
          _countdown = 30;
          _showResendButton = false;
        });
        _startCountdown();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo de verificación reenviado')),
        );
      }
    } catch (e) {
      setState(() {
        _isSendingEmail = false;
      });

      if (e is FirebaseAuthException && e.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Demasiados intentos. Intenta más tarde.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reenviar el correo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Usuario"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              child: Card(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Crear una Cuenta",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Correo Electrónico",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Este campo es obligatorio";
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return "Ingrese un correo válido";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Este campo es obligatorio";
                            }
                            if (value.length < 6) {
                              return "Debe tener al menos 6 caracteres";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        if (!_isEmailSent)
                          ElevatedButton(
                            onPressed: _registerUser,
                            child: const Text("Registrar"),
                          ),
                        const SizedBox(height: 20),
                        if (!_showResendButton)
                          Text(
                            "Espera $_countdown segundos para reenviar.",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        if (_showResendButton)
                          TextButton(
                            onPressed: _isSendingEmail
                                ? null
                                : _resendVerificationEmail,
                            child: _isSendingEmail
                                ? const CircularProgressIndicator()
                                : const Text("Reenviar correo de verificación"),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
