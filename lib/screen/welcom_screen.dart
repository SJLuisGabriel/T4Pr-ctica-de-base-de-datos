import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t4bd/firebase/usuarios_firebase.dart';
import 'package:t4bd/settings/user_data_provider.dart';

class WelcomScreen extends StatefulWidget {
  const WelcomScreen({super.key});

  @override
  _WelcomScreenState createState() => _WelcomScreenState();
}

class _WelcomScreenState extends State<WelcomScreen> {
  bool _isNavigating = false; // Flag para controlar la navegación

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final metodo = args['metodo'] ?? 'Desconocido';
    final correo = args['correo'] ?? 'No disponible';
    final nombre = args['nombre'] ?? '';
    final foto = args['foto'] ?? 'assets/perfil2.jpg';
    final suscripcion = args['suscripcion'] ?? 'ninguna';

    final firebaseService = FirebaseService();

    return FutureBuilder<String>(
      future: _checkUserStatus(
          correo, metodo, nombre, foto, suscripcion, firebaseService, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Indicador de carga
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final statusUser = snapshot.data;

        // Aseguramos que la navegación solo ocurra una vez
        if (!_isNavigating) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (statusUser == "NUEVO") {
              setState(() {
                _isNavigating = true; // Evitar navegación múltiple
              });
              Navigator.pushReplacementNamed(context, '/onboarding');
            } else if (statusUser == "VIEJO") {
              setState(() {
                _isNavigating = true; // Evitar navegación múltiple
              });
              Navigator.pushReplacementNamed(context, '/home');
            }
          });
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<String> _checkUserStatus(
    String correo,
    String metodo,
    String nombre,
    String foto,
    String suscripcion,
    FirebaseService firebaseService,
    BuildContext context,
  ) async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    String statusUser = '';

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('correo', isEqualTo: correo)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        userDataProvider.setCorreo(userData['correo'] ?? '');
        userDataProvider.setMetodo(metodo);
        userDataProvider.setNombreUsuario(userData['nombre'] ?? '');
        userDataProvider.setFoto(userData['foto'] ?? '');
        userDataProvider.setSuscripcion(userData['suscripcion'] ?? 'ninguna');
        statusUser = "VIEJO"; // Usuario viejo
      } else {
        await firebaseService.addUser(
          correo: correo,
          foto: foto,
          nombre: nombre,
          registro: "si",
          suscripcion: "ninguna",
          createdAt: DateTime.now(),
        );
        userDataProvider.setCorreo(correo);
        userDataProvider.setMetodo(metodo);
        userDataProvider.setNombreUsuario(nombre);
        userDataProvider.setFoto(foto);
        statusUser = "NUEVO"; // Usuario nuevo
      }
    } catch (e) {
      print("Error al verificar o agregar el usuario: $e");
      statusUser = "ERROR";
    }

    return statusUser;
  }
}
