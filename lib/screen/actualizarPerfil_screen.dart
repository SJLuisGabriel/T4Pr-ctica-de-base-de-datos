import 'dart:io';
import 'package:t4bd/firebase/usuarios_firebase.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:t4bd/screen/services/supabase_service.dart';
import 'package:t4bd/settings/ThemeProvider.dart';
import 'package:t4bd/settings/user_data_provider.dart';

class ActualizarperfilScreen extends StatefulWidget {
  const ActualizarperfilScreen({super.key});

  @override
  State<ActualizarperfilScreen> createState() => _ActualizarperfilScreenState();
}

class _ActualizarperfilScreenState extends State<ActualizarperfilScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de los formularios
  late TextEditingController _correoController;
  late TextEditingController _nombreUsuarioController;
  late TextEditingController _fotoController;
  late TextEditingController _metodoController;
  late TextEditingController _edadController;
  late TextEditingController _ubicacionController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _telefonoController;
  String? _imagenTemporal;
  final firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();

    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);

    _nombreUsuarioController =
        TextEditingController(text: userDataProvider.nombreUsuario);
    _metodoController = TextEditingController(text: userDataProvider.metodo);
    _edadController =
        TextEditingController(text: userDataProvider.edad.toString());
    _ubicacionController =
        TextEditingController(text: userDataProvider.ubicacion);
    _fechaNacimientoController =
        TextEditingController(text: userDataProvider.fechaNacimiento);
    _telefonoController =
        TextEditingController(text: userDataProvider.telefono);
    _correoController = TextEditingController(text: userDataProvider.correo);
    _fotoController = TextEditingController(text: userDataProvider.foto);

    // Inicializa la imagen temporal con la actual
    _imagenTemporal = userDataProvider.foto;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime initialDate = DateTime(2000, 1, 1);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _fechaNacimientoController.text =
            "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    final suscripcion =
        Provider.of<UserDataProvider>(context, listen: false).suscripcion;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Seleccionar Imagen',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Imagen 1
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _imagenTemporal = 'assets/perfil2.jpg';
                    });
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('assets/perfil2.jpg'),
                  ),
                ),
                const SizedBox(height: 10),
                // Imagen 2
                GestureDetector(
                  onTap: () {
                    if (suscripcion != "ninguna") {
                      setState(() {
                        _imagenTemporal = 'assets/perfil1.jpg';
                      });
                      Navigator.of(context).pop();
                    } else {}
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Imagen de perfil
                      const CircleAvatar(
                        radius: 70,
                        backgroundImage: AssetImage('assets/perfil1.jpg'),
                      ),
                      if (suscripcion == "ninguna")
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: const Opacity(
                            opacity: 0.9,
                            child: Icon(
                              Icons.block,
                              color: Colors.yellow,
                              size: 100,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Imagen 3
                GestureDetector(
                  onTap: () {
                    if (suscripcion != "ninguna") {
                      setState(() {
                        _imagenTemporal = 'assets/perfil3.jpg';
                      });
                      Navigator.of(context).pop();
                    } else {}
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Imagen de perfil
                      const CircleAvatar(
                        radius: 70,
                        backgroundImage: AssetImage('assets/perfil3.jpg'),
                      ),
                      if (suscripcion == "ninguna")
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: const Opacity(
                            opacity: 0.9,
                            child: Icon(
                              Icons.block,
                              color: Colors.yellow,
                              size: 100,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Imagen 4
                GestureDetector(
                  onTap: () {
                    if (suscripcion != "ninguna") {
                      setState(() {
                        _imagenTemporal = 'assets/perfil4.jpg';
                      });
                      Navigator.of(context).pop();
                    } else {}
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Imagen de perfil
                      const CircleAvatar(
                        radius: 70,
                        backgroundImage: AssetImage('assets/perfil4.jpg'),
                      ),
                      if (suscripcion == "ninguna")
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: const Opacity(
                            opacity: 0.9,
                            child: Icon(
                              Icons.block,
                              color: Colors.yellow,
                              size: 100,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Seleccionar desde la galería
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      setState(() {
                        _imagenTemporal = pickedFile.path;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    _nombreUsuarioController.dispose();
    _fotoController.dispose();
    _metodoController.dispose();
    _edadController.dispose();
    _ubicacionController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suscripcion = Provider.of<UserDataProvider>(context).suscripcion;
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final correo = userDataProvider.correo; // Se usa el correo del provider
    final foto = userDataProvider.foto;
    final supabaseService = SupabaseService();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Builder(
          builder: (context) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            return Text(
              'Actualizar Perfil',
              style: TextStyle(
                fontFamily: themeProvider.currentFont,
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: userDataProvider.metodo == "Correo y Contraseña"
                      ? _seleccionarImagen // Usamos el nuevo método
                      : null,
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.2,
                    backgroundImage: _imagenTemporal != null
                        ? (_imagenTemporal!.startsWith('http')
                            ? NetworkImage(_imagenTemporal!) // Si es una URL
                            : (_imagenTemporal!.startsWith('assets/')
                                ? AssetImage(_imagenTemporal!)
                                    as ImageProvider // Si es un asset
                                : FileImage(
                                    File(_imagenTemporal!),
                                  ))) // Si es una ruta local
                        : const AssetImage('assets/perfil2.jpg'),
                  ),
                ),
                const SizedBox(height: 20),
                if (userDataProvider.metodo != "Correo y Contraseña")
                  const Text(
                    "La imagen solo se puede editar con método 'Correo y Contraseña'",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreUsuarioController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre de Usuario'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre de usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _edadController,
                  decoration: const InputDecoration(labelText: 'Edad'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ubicacionController,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fechaNacimientoController,
                  decoration:
                      const InputDecoration(labelText: 'Fecha de Nacimiento'),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          try {
                            String? publicUrl;

                            // Validar si el método permite modificar la imagen
                            if (userDataProvider.metodo ==
                                    "Correo y Contraseña" &&
                                !_imagenTemporal!.startsWith('asset')) {
                              // Si la imagen temporal es un archivo local, súbela a Supabase
                              publicUrl =
                                  await supabaseService.uploadProfileImage(
                                correo, // Asume que "correo" es el userId en Supabase
                                _imagenTemporal!,
                              );

                              // if (publicUrl == null) {
                              //   throw Exception('Error al subir la imagen');
                              // }
                            }

                            // Preparar los datos actualizados
                            final updatedData = {
                              'nombre': _nombreUsuarioController.text,
                              'edad': int.parse(_edadController.text),
                              'ubicacion': _ubicacionController.text,
                              'fechaNacimiento':
                                  _fechaNacimientoController.text,
                              'telefono': _telefonoController.text,
                              // La foto solo se actualiza si se subió una nueva imagen, de lo contrario, se usa la actual
                              if (userDataProvider.metodo ==
                                  "Correo y Contraseña")
                                'foto': publicUrl ?? _imagenTemporal,
                            };

                            // Actualizar los datos en Firebase
                            await firebaseService.updateUserByEmail(
                                correo, updatedData);

                            // Actualizar los datos en el Provider
                            userDataProvider.setNombreUsuario(
                                _nombreUsuarioController.text);
                            userDataProvider
                                .setEdad(int.parse(_edadController.text));
                            userDataProvider
                                .setTelefono(_telefonoController.text);
                            userDataProvider.setFechaNacimiento(
                                _fechaNacimientoController.text);
                            userDataProvider
                                .setUbicacion(_ubicacionController.text);

                            // Solo actualizar la foto en el Provider si se permite modificarla
                            if (userDataProvider.metodo ==
                                "Correo y Contraseña") {
                              userDataProvider
                                  .setFoto(publicUrl ?? _imagenTemporal!);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Perfil actualizado exitosamente')),
                            );

                            Navigator.of(context).pop(); // Cierra la pantalla
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Guardar Cambios'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _imagenTemporal = userDataProvider
                              .foto; // Restaura la imagen original
                        });
                        Navigator.of(context).pop(); // Cierra la pantalla
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
