import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t4bd/settings/ThemeProvider.dart';
import 'package:t4bd/settings/user_data_provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  void initState() {
    super.initState();
  }

  // Función para navegar y enviar datos a la pantalla de actualización
  void _navigateToUpdatePerfil(
      BuildContext context,
      String metodo,
      String correo,
      String? nombre,
      String? foto,
      String edad,
      String ubicacion,
      String telefono) {
    Navigator.pushNamed(
      context,
      '/actualizarperfil',
      arguments: {
        'metodo': metodo,
        'correo': correo,
        'nombre': nombre ?? 'No disponible',
        'foto': foto ?? '',
        'edad': edad,
        'ubicacion': ubicacion,
        'telefono': telefono,
      },
    );
  }

  void _showUserDetailsModal(BuildContext context, String nombre, String correo,
      String telefono, String ubicacion, String edad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Detalles del Usuario',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                _buildDetailRow('Nombre', nombre),
                _buildDetailRow('Correo', correo),
                _buildDetailRow('Teléfono', telefono),
                _buildDetailRow('Ubicación', ubicacion),
                _buildDetailRow('Edad', '$edad años'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final correo = Provider.of<UserDataProvider>(context).correo;
    final nombreUsuario = Provider.of<UserDataProvider>(context).nombreUsuario;
    final foto = Provider.of<UserDataProvider>(context).foto;
    final metodo = Provider.of<UserDataProvider>(context).metodo;
    final edad = Provider.of<UserDataProvider>(context).edad.toString();
    final ubicacion = Provider.of<UserDataProvider>(context).ubicacion;
    final telefono = Provider.of<UserDataProvider>(context).telefono;

    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            return Text(
              'Inicio',
              style: TextStyle(
                fontFamily: themeProvider.currentFont,
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Foto de perfil
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.2,
                backgroundImage: foto.startsWith('asset/')
                    ? AssetImage(foto) as ImageProvider
                    : foto.startsWith('http')
                        ? NetworkImage(foto)
                        : File(foto).existsSync()
                            ? FileImage(File(foto)) as ImageProvider
                            : const AssetImage('assets/perfil2.jpg'),
              ),
              const SizedBox(height: 20),

              // Información del usuario
              Text(nombreUsuario,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      )),

              const SizedBox(height: 10),
              Text(
                correo,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              // Botón de editar perfil
              ElevatedButton.icon(
                onPressed: () {
                  _navigateToUpdatePerfil(context, metodo, correo,
                      nombreUsuario, foto, edad, ubicacion, telefono);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar Perfil'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.8,
                    50,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  _showUserDetailsModal(
                    context,
                    nombreUsuario,
                    correo,
                    telefono,
                    ubicacion,
                    edad,
                  );
                },
                icon: const Icon(Icons.info),
                label: const Text('Ver Más Detalles'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.8,
                    50,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Información adicional
              Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información Adicional',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Teléfono'),
                        subtitle: Text(telefono),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text('Ubicación'),
                        subtitle: Text(ubicacion),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
