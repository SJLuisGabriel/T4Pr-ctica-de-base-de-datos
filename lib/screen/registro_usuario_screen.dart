import 'package:flutter/material.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fechaNacimientoController = TextEditingController();

  @override
  void dispose() {
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  Future<void> _selectFechaNacimiento(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _fechaNacimientoController.text =
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Usuario"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(
                  horizontal: isDesktop ? constraints.maxWidth * 0.2 : 16,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Crear una Cuenta",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Nombre de Usuario",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Este campo es obligatorio";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Nombre(s) y Apellidos",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Este campo es obligatorio";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Correo Electrónico",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Este campo es obligatorio";
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return "Ingrese un correo válido";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Este campo es obligatorio";
                            }
                            if (value.length < 6) {
                              return "Debe tener al menos 6 caracteres";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _fechaNacimientoController,
                          decoration: const InputDecoration(
                            labelText: "Fecha de Nacimiento",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectFechaNacimiento(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Seleccione su fecha de nacimiento";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Registrado con éxito")),
                              );
                            }
                          },
                          child: const Text("Registrar"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
