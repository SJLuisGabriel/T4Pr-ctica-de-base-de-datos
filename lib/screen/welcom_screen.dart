import 'dart:io';
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

    Future.microtask(() async {
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);

      try {
        // Buscar el usuario por correo en Firebase
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
        }

        foto = userDataProvider.foto;
      } catch (e) {
        print("Error al verificar o agregar el usuario: $e");
      }
    });

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Configuración basada en el ancho de la pantalla
          final isDesktop = constraints.maxWidth > 600;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Foto del usuario
                  Expanded(
                    flex: isDesktop ? 1 : 0,
                    child: Consumer<UserDataProvider>(
                      builder: (context, userDataProvider, _) {
                        return CircleAvatar(
                          radius: isDesktop
                              ? constraints.maxWidth * 0.1
                              : constraints.maxWidth * 0.2,
                          backgroundImage: metodo.startsWith('Correo')
                              ? foto.startsWith('asset')
                                  ? AssetImage(foto)
                                  : foto.startsWith('http')
                                      ? NetworkImage(foto)
                                      : File(foto).existsSync()
                                          ? FileImage(File(foto))
                                              as ImageProvider
                                          : const AssetImage(
                                              'assets/perfil1.jpg')
                              : NetworkImage(foto),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                      width: isDesktop ? 40 : 0, height: isDesktop ? 0 : 20),

                  // Información del usuario
                  Expanded(
                    flex: isDesktop ? 2 : 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Consumer<UserDataProvider>(
                          builder: (context, userDataProvider, _) {
                            return Text(
                              'BIENVENIDO: ${userDataProvider.nombreUsuario}',
                              style: TextStyle(
                                fontSize: isDesktop ? 32 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 60 : 40,
                              vertical: 15,
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            textStyle: TextStyle(
                              fontSize: isDesktop ? 20 : 18,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: const Text('Ir a la Pantalla de Inicio'),
                        ),
                        const SizedBox(height: 20),
                        Consumer<UserDataProvider>(
                          builder: (context, userDataProvider, _) {
                            return Column(
                              children: [
                                Text(
                                  'Método de inicio: ${userDataProvider.metodo}',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 20 : 18,
                                  ),
                                ),
                                Text(
                                  'Correo: ${userDataProvider.correo}',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 20 : 18,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
