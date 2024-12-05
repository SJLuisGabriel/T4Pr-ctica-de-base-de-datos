import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t4bd/firebase/usuarios_firebase.dart';
import 'package:t4bd/settings/user_data_provider.dart';

class WelcomScreen extends StatelessWidget {
  const WelcomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibir los argumentos
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final metodo = args['metodo'] ?? 'Desconocido';
    final correo = args['correo'] ?? 'No disponible';
    final nombre = args['nombre'] ?? '';
    var foto = args['foto'] ?? 'assets/perfil2.jpg';
    final firebaseService = FirebaseService();

    // Usar un FutureBuilder para gestionar el estado de carga y la verificación
    return FutureBuilder<String>(
      future: _checkUserStatus(
          correo, metodo, nombre, foto, firebaseService, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar pantalla de carga mientras se verifica el estado
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Indicador de carga
            ),
          );
        }

        if (snapshot.hasError) {
          // Si hay un error, se muestra un mensaje de error
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        // Después de la verificación, si el usuario es nuevo o no
        final statusUser = snapshot.data;
        if (statusUser == "NUEVO") {
          // Redirigir a la pantalla de bienvenida si es nuevo usando la ruta definida
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacementNamed(context, '/onboarding');
          });
        } else if (statusUser == "VIEJO") {
          // Redirigir a la pantalla principal si el usuario es viejo usando la ruta definida
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }

        // Mientras no se haya redirigido, mostrar algo en la pantalla
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Indicador de carga
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
      FirebaseService firebaseService,
      BuildContext context) async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    String statusUser = '';

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('correo', isEqualTo: correo)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Usuario ya registrado
        final userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;

        userDataProvider.setCorreo(userData['correo'] ?? '');
        userDataProvider.setMetodo(metodo);
        userDataProvider.setNombreUsuario(userData['nombre'] ?? '');
        userDataProvider.setFoto(userData['foto'] ?? '');
        statusUser = "VIEJO"; // Usuario viejo
      } else {
        // Usuario nuevo
        await firebaseService.addUser(
          correo: correo,
          foto: foto,
          nombre: nombre,
          registro: "si",
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
