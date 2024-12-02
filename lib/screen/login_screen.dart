import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:github_signin_promax/github_signin_promax.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _navigateToWelcome(BuildContext context, String metodo, String correo) {
    Navigator.pushReplacementNamed(context, '/welcome',
        arguments: {'metodo': metodo, 'correo': correo});
  }

  Future<void> signInWithEmailPassword(
      String email, String password, BuildContext context) async {
    try {
      // Intentamos el inicio de sesión
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print('Inicio de sesión exitoso: ${userCredential.user?.email}');
      _navigateToWelcome(context, 'Correo y Contraseña', email);
    } catch (e) {
      print('Error de inicio de sesión: $e');

      // Mostrar un mensaje de error en caso de fallo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de inicio de sesión credenciales no validas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signInWithGoogle(BuildContext context, String email) async {
    try {
      // Crear una instancia de GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Intentamos realizar el inicio de sesión con Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        print('El usuario canceló el inicio de sesión');
        return;
      }

      // Obtener el objeto de autenticación de Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear un objeto de credenciales con el ID y token de acceso
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión con las credenciales de Google en Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print(
          'Inicio de sesión con Google exitoso: ${userCredential.user?.email}');
      _navigateToWelcome(context, 'Google', email);
    } catch (e) {
      print('Error de inicio de sesión con Google: $e');

      // Mostrar un mensaje de error en caso de fallo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de inicio de sesión con Google'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signInWithGitHub(BuildContext contex, String email) async {
    try {
      var params = GithubSignInParams(
        clientId: 'Ov23li0tfSzU6owukeDA',
        clientSecret: 'bd356b431054da2e839c6b96a72d3bbdf169188e',
        redirectUrl:
            'https://registrousuarios-9c9b2.firebaseapp.com/__/auth/handler',
        scopes: 'read:user,user:email',
      );

      final result = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (builder) {
        return GithubSigninScreen(
          params: params,
          headerColor: Colors.green,
          title: 'Login with GitHub',
        );
      }));

      if (result != null) {
        final accessToken = result.accessToken;

        if (accessToken != null) {
          // Usar el token de acceso para obtener las credenciales de GitHub
          final authCredential = GithubAuthProvider.credential(accessToken);
          final userCredential =
              await FirebaseAuth.instance.signInWithCredential(authCredential);

          print(
              'Inicio de sesión exitoso con GitHub: ${userCredential.user?.email}');
          _navigateToWelcome(context, 'Github', email);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // Si la cuenta ya existe con otro proveedor, muestra un mensaje al usuario
        print('El correo ya está asociado con otra cuenta de autenticación.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'El correo ya está asociado con otra cuenta de autenticación.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print('Error de inicio de sesión con GitHub: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de inicio de sesión con GitHub'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error de inicio de sesión con GitHub: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de inicio de sesión con GitHub'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signInWithFacebook(BuildContext context, String email) async {
    try {
      print("Inicio de sesión con Facebook iniciado");

      // Inicia el inicio de sesión con Facebook
      final LoginResult result = await FacebookAuth.i.login(
        permissions: ['email', 'public_profile'],
      );

      // Verifica el resultado del inicio de sesión
      if (result.status == LoginStatus.success) {
        // Si el inicio de sesión fue exitoso, obtenemos el token
        final accessToken = result.accessToken;

        // Crear las credenciales de Firebase con el token de acceso
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken!.token);

        // Iniciar sesión en Firebase con las credenciales obtenidas
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Si el inicio de sesión es exitoso, mostramos el correo del usuario
        print(
            'Inicio de sesión con Facebook exitoso: ${userCredential.user?.email}');

        // Navegar a la pantalla de bienvenida
        _navigateToWelcome(context, 'Facebook', email);
      } else {
        // Si el inicio de sesión fue cancelado o falló
        print('Error de inicio de sesión con Facebook: ${result.status}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de inicio de sesión con Facebook'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // En caso de que ocurra un error
      print('Error de inicio de sesión con Facebook: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de inicio de sesión con Facebook'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

                        // Campo de texto para el Correo
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
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
                            signInWithEmailPassword(_emailController.text,
                                _passwordController.text, context);
                          },
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
                          child: const Text('Iniciar sesión'),
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
                          onPressed: () {
                            signInWithGoogle(context, _emailController.text);
                          },
                          icon: const Icon(Icons.golf_course),
                          label: const Text('Iniciar sesión con Google'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
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
                          onPressed: () {
                            print("object");
                            signInWithFacebook(context, _emailController.text);
                          },
                          icon: const Icon(Icons.facebook),
                          label: const Text('Iniciar sesión con Facebook'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
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
                          onPressed: () {
                            signInWithGitHub(context, _emailController.text);
                          },
                          icon: const Icon(Icons.code),
                          label: const Text('Iniciar sesión con GitHub'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
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
