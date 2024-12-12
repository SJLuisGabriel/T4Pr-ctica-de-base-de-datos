import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t4bd/firebase/alta_producto_firebase.dart';

class AltaProducto extends StatefulWidget {
  const AltaProducto({super.key});

  @override
  State<AltaProducto> createState() => _AltaProductoState();
}

class _AltaProductoState extends State<AltaProducto> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final AltaProductoFirebase _imgService = AltaProductoFirebase();
  File? _imageFile;

  // Instance of ProductService
  final AltaProductoFirebase _altaService = AltaProductoFirebase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Agregar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el stock';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _imageFile != null
                  ? Column(
                      children: [
                        Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
                        TextButton.icon(
                          onPressed: _clearImage,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Eliminar Imagen',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  : const Placeholder(
                      fallbackHeight: 200,
                    ),
              TextButton.icon(
                onPressed: _showImageSourceModal,
                icon: const Icon(Icons.image),
                label: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to save the product
  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Upload image and get URL
        final imageUrl = await _altaService.uploadImage(_imageFile!);
        await _altaService.addProduct(
          name: _nameController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          imageUrl: imageUrl,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto agregado exitosamente')),
        );

        // Clear the form fields
        _nameController.clear();
        _descriptionController.clear();
        _categoryController.clear();
        _priceController.clear();
        _stockController.clear();
        setState(() {
          _imageFile = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar producto: $e')),
        );
      }
    }
  }

  // Method to show modal for image source selection
  Future<void> _showImageSourceModal() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        );
      },
    );
  }

  // Method to pick an image from the specified source
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Method to clear the selected image
  void _clearImage() {
    setState(() {
      _imageFile = null;
    });
  }
}
