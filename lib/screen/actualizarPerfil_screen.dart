import 'dart:io';
import 'package:t4bd/firebase/usuarios_firebase.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final correo = userDataProvider.correo; // Se usa el correo del provider
    final foto = userDataProvider.foto;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Perfil'),
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
                      ? () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);

                          if (pickedFile != null) {
                            setState(() {
                              _imagenTemporal = pickedFile
                                  .path; // Actualiza la imagen temporal
                            });
                          }
                        }
                      : null,
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.2,
                    backgroundImage: _imagenTemporal != null &&
                            File(_imagenTemporal!).existsSync()
                        ? FileImage(File(_imagenTemporal!))
                        : (foto != null
                                ? (foto.startsWith('http')
                                    ? NetworkImage(foto) // Imagen desde URL
                                    : FileImage(File(foto))) // Imagen local
                                : const AssetImage('assets/perfil2.jpg'))
                            as ImageProvider,
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
                          final updatedData = {
                            'nombre': _nombreUsuarioController.text,
                            'edad': int.parse(_edadController.text),
                            'ubicacion': _ubicacionController.text,
                            'fechaNacimiento': _fechaNacimientoController.text,
                            'telefono': _telefonoController.text,
                            'foto': _imagenTemporal ?? userDataProvider.foto,
                          };

                          await firebaseService.updateUserByEmail(
                            correo, // Usamos el correo del userDataProvider
                            updatedData,
                          );

                          // Actualizamos los datos en el Provider
                          userDataProvider
                              .setNombreUsuario(_nombreUsuarioController.text);
                          userDataProvider
                              .setEdad(int.parse(_edadController.text));
                          userDataProvider
                              .setTelefono(_telefonoController.text);
                          userDataProvider.setFechaNacimiento(
                              _fechaNacimientoController.text);
                          userDataProvider
                              .setUbicacion(_ubicacionController.text);
                          userDataProvider.setFoto(
                              _imagenTemporal ?? userDataProvider.foto);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Perfil actualizado exitosamente')),
                          );

                          Navigator.of(context).pop(); // Cierra la pantalla
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
