import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Variables de estado para la información del usuario
  String nombre = 'Nombre del Usuario';
  String foto = 'assets/perfil4.jpg'; // Imagen por defecto
  String fechaNacimiento = '01/01/1990';
  String phone = '4612992772';
  int edad = 34;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Cargar la imagen de perfil desde SharedPreferences (si está guardada)
  void _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      foto = prefs.getString('profileImage') ??
          'assets/perfil4.jpg'; // Si no hay imagen guardada, usa la predeterminada
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto de perfil
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.2,
                backgroundImage: foto.startsWith('assets')
                    ? AssetImage(foto)
                    : FileImage(File(foto)) as ImageProvider,
              ),
              const SizedBox(height: 20),

              // Información del usuario
              Text(
                nombre,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'correo@ejemplo.com',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              // Botones de acciones
              ElevatedButton.icon(
                onPressed: () {
                  _showEditProfileDialog(context);
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
                  // Acción para ver más detalles
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
                margin: EdgeInsets.all(8.0),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
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
                        subtitle: Text(phone),
                      ),
                      const ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text('Ubicación'),
                        subtitle: Text('Ciudad, País'),
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

  // Función para mostrar el modal de edición de perfil
  void _showEditProfileDialog(BuildContext context) {
    _nombreController.text = nombre;
    _fechaController.text = fechaNacimiento;
    _edadController.text = edad.toString();
    _phoneController.text = phone.toString();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.only(top: 50),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Foto de perfil:'),
                    subtitle: Center(
                      child: GestureDetector(
                        onTap: () {
                          _showPhotoSelectDialog(context);
                        },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: foto.startsWith('assets')
                              ? AssetImage(foto)
                              : FileImage(File(foto)) as ImageProvider,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Editar nombre
                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Editar fecha de nacimiento
                  TextField(
                    controller: _fechaController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Nacimiento (dd/mm/yyyy)',
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 20),

                  // Editar edad
                  TextField(
                    controller: _edadController,
                    decoration: const InputDecoration(
                      labelText: 'Edad',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Editar Teléfono
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),

                  // Botones para guardar o cancelar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            nombre = _nombreController.text;
                            fechaNacimiento = _fechaController.text;
                            edad = int.tryParse(_edadController.text) ?? edad;
                            phone = _phoneController.text;
                          });
                          Navigator.of(context).pop();
                          _saveProfileData();
                        },
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Función para guardar la foto de perfil en SharedPreferences
  void _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profileImage', foto);
  }

  // Función para mostrar un diálogo con opciones de imágenes predefinidas
  void _showPhotoSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Selecciona una foto de perfil'),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPhotoOption(context, 'assets/perfil1.jpg'),
                  _buildPhotoOption(context, 'assets/perfil2.jpg'),
                  _buildPhotoOption(context, 'assets/perfil3.jpg'),
                  _buildPhotoOption(context, 'assets/perfil4.jpg'),
                  _buildCameraOption(),
                  _buildGalleryOption(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget para una opción de imagen predefinida
  Widget _buildPhotoOption(BuildContext parentContext, String imagePath) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          foto = imagePath;
        });
        Navigator.of(parentContext).pop();
        Navigator.of(context).pop();
        _saveProfileData();
        Future.delayed(Duration.zero, () {
          _showEditProfileDialog(context);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: CircleAvatar(
          radius: 70,
          backgroundImage: AssetImage(imagePath),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  // Widget para la opción de cámara
  Widget _buildCameraOption() {
    return SimpleDialogOption(
      onPressed: () async {
        final XFile? photo =
            await _picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          setState(() {
            foto = photo.path;
          });
          _saveProfileData();
        }
        Navigator.of(context).pop();
      },
      child: const Icon(Icons.camera_alt),
    );
  }

  // Widget para la opción de galería
  Widget _buildGalleryOption() {
    return SimpleDialogOption(
      onPressed: () async {
        final XFile? photo =
            await _picker.pickImage(source: ImageSource.gallery);
        if (photo != null) {
          setState(() {
            foto = photo.path;
          });
          _saveProfileData();
        }
        Navigator.of(context).pop();
      },
      child: const Icon(Icons.photo),
    );
  }
}
