import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:github_signin_promax/github_signin_promax.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _navigateToWelcome(BuildContext context, String metodo, String correo,
      String? nombre, String? foto) {
    Navigator.pushReplacementNamed(
      context,
      '/welcome',
      arguments: {
        'metodo': metodo,
        'correo': correo,
        'nombre': nombre ?? 'No disponible',
        'foto': foto ?? '',
      },
    );
  }

  Future<void> signInWithEmailPassword(
      String email, String password, BuildContext context) async {
    try {
      // Intentamos el inicio de sesión
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print('Inicio de sesión exitoso: ${userCredential.user?.email}');

      final User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          // Si el correo no está verificado, mostramos un mensaje y redirigimos al login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, verifica tu correo electrónico.'),
              backgroundColor: Colors.orange,
            ),
          );
          // Puedes hacer algo aquí para que el usuario se quede en la pantalla de login
          return; // Detenemos la ejecución
        } else {
          // Si el correo está verificado, seguimos con el proceso
          String name = email.split('@')[0];
          _navigateToWelcome(context, 'Correo y Contraseña', email, name,
              'assets/perfil2.jpg');
        }
      }
    } catch (e) {
      print('Error de inicio de sesión: $e');

      // Mostrar un mensaje de error en caso de fallo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de inicio de sesión: credenciales no válidas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Crear una instancia de GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Intentar iniciar sesión con Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('El usuario canceló el inicio de sesión');
        return;
      }

      // Obtener la información del usuario
      final String? nombre = googleUser.displayName;
      final String? foto = googleUser.photoUrl;

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

      // Llamar a la navegación incluyendo los nuevos datos
      _navigateToWelcome(context, 'Google',
          userCredential.user?.email ?? 'No disponible', nombre, foto);
    } catch (e) {
      print('Error de inicio de sesión con Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de inicio de sesión con Google'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signInWithGitHub(BuildContext context) async {
    try {
      // Configuración de los parámetros de autenticación
      var params = GithubSignInParams(
        clientId: 'Ov23li0tfSzU6owukeDA',
        clientSecret: 'bd356b431054da2e839c6b96a72d3bbdf169188e',
        redirectUrl:
            'https://registrousuarios-9c9b2.firebaseapp.com/__/auth/handler',
        scopes: 'read:user,user:email',
      );

      // Navegar al flujo de inicio de sesión de GitHub
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

          // Obtener información adicional del usuario desde GitHub
          final User? user = userCredential.user;

          final String? email = user?.email;
          final String? nombre = user?.displayName;
          final String? foto = user?.photoURL;

          print('Inicio de sesión exitoso con GitHub:');
          print('Email: $email');
          print('Nombre: $nombre');
          print('Foto: $foto');

          // Navegar a la pantalla de bienvenida con los datos del usuario
          _navigateToWelcome(
            context,
            'GitHub',
            email ?? 'No disponible',
            nombre ?? 'Desconocido',
            foto ?? '',
          );
        } else {
          print('El token de acceso de GitHub es nulo.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al obtener el token de acceso de GitHub'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Inicio de sesión con GitHub cancelado.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión con GitHub cancelado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
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
      print('Error inesperado durante el inicio de sesión con GitHub: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Error inesperado durante el inicio de sesión con GitHub'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      print("Inicio de sesión con Facebook iniciado");

      // Inicia el inicio de sesión con Facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      // Verifica el resultado del inicio de sesión
      if (result.status == LoginStatus.success) {
        // Obtén el token de acceso
        final AccessToken accessToken = result.accessToken!;

        // Crear las credenciales de Firebase con el token de acceso
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);

        // Iniciar sesión en Firebase con las credenciales obtenidas
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Obtener información adicional del usuario desde Facebook
        final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,picture.width(200)",
        );

        final String? correo = userData['email'] as String?;
        final String? nombre = userData['name'] as String?;
        final String? foto = userData['picture']['data']['url'] as String?;

        // Navegar a la pantalla de bienvenida con los datos del usuario
        _navigateToWelcome(
          context,
          'Facebook', // El método de inicio de sesión
          correo ?? 'No disponible', // Correo o valor por defecto
          nombre ?? 'No disponible', // Nombre o valor por defecto
          foto ?? '', // Foto de perfil o valor por defecto
        );
      } else {
        // Si el inicio de sesión fue cancelado o falló
        print('Error de inicio de sesión con Facebook: ${result.status}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de inicio de sesión con Facebook'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Manejo de errores
      print('Error de inicio de sesión con Facebook: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
                            signInWithGoogle(context);
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
                            signInWithFacebook(
                              context,
                            );
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
                            signInWithGitHub(context);
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
