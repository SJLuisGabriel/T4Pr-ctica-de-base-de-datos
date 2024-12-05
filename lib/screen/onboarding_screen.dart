import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t4bd/settings/user_data_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
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
                        // Obtener los datos del proveedor
                        String foto = userDataProvider.foto;
                        String metodo = userDataProvider.metodo;
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
                            // Obtener el nombre del usuario
                            String nombreUsuario =
                                userDataProvider.nombreUsuario;
                            return Text(
                              'BIENVENIDO: $nombreUsuario',
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
                                // Obtener método y correo
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
