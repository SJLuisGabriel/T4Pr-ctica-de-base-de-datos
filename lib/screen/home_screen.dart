import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<DateTime, List<Map<String, dynamic>>> events;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  String _profileImage = 'assets/perfil1.jpg'; // Imagen por defecto

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // Cargar la imagen al iniciar

    events = {
      DateTime.now(): [
        {'status': 'pending', 'description': 'Venta 1'},
        {'status': 'completed', 'description': 'Servicio 1'},
      ],
      DateTime.now().add(const Duration(days: 1)): [
        {'status': 'cancelled', 'description': 'Venta 2'},
      ],
      DateTime.now().add(const Duration(days: 2)): [
        {'status': 'pending', 'description': 'Venta 3'},
        {'status': 'completed', 'description': 'Servicio 2'},
        {'status': 'pending', 'description': 'Venta 4'},
      ],
      DateTime.now().add(const Duration(days: 3)): [
        {'status': 'completed', 'description': 'Servicio 3'},
      ],
      DateTime.now().add(const Duration(days: 5)): [
        {'status': 'cancelled', 'description': 'Venta 5'},
      ],
      DateTime.now().add(const Duration(days: 7)): [
        {'status': 'completed', 'description': 'Servicio 4'},
        {'status': 'pending', 'description': 'Venta 6'},
      ],
    };
    _loadProfileImage();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.green; // Por cumplir
      case 'cancelled':
        return Colors.red; // Cancelado
      case 'completed':
        return Colors.white; // Completado
      default:
        return Colors.grey; // Por defecto
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signOutWithGoogle() async {
    try {
      // Cerrar sesión de Google
      await _googleSignIn.signOut();

      // Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();

      print('Sesión cerrada de Google y Firebase');

      // Opcional: Redirigir a la pantalla de inicio de sesión
      Navigator.pushReplacementNamed(context, '/login');

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');

      // Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEventsForDay(DateTime day) {
    final dayEvents = events[day] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Eventos del ${day.day}/${day.month}/${day.year}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: dayEvents.length,
                  itemBuilder: (context, index) {
                    final event = dayEvents[index];
                    return ListTile(
                      title: Text(event['description']),
                      subtitle: Text(event['status']),
                      tileColor: getStatusColor(event['status']),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Función para cargar la imagen guardada desde SharedPreferences
  void _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath =
        prefs.getString('profileImage'); // Obtener la ruta de la imagen

    if (imagePath != null) {
      setState(() {
        _profileImage = imagePath; // Actualiza la imagen de perfil
      });
    }
  }

  // Función para guardar la imagen seleccionada en SharedPreferences
  void _saveProfileImage(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profileImage', imagePath);

    setState(() {
      _profileImage = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
                _showEventsForDay(selectedDay);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final dayEvents = events[day] ?? [];
                  Color pointColor;

                  if (dayEvents.isEmpty) {
                    pointColor = Colors.transparent; // Sin eventos
                  } else if (dayEvents
                      .any((event) => event['status'] == 'cancelled')) {
                    pointColor = Colors.red; // Al menos un cancelado
                  } else if (dayEvents
                      .any((event) => event['status'] == 'pending')) {
                    pointColor = Colors.green; // Al menos un pendiente
                  } else {
                    pointColor = Colors.white; // Completado
                  }

                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            day.day.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      if (dayEvents.isNotEmpty)
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              color: pointColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${dayEvents.length}',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/pendientes');
              },
              child: const Text('Ventas Pendientes'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Realizar Ventas'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/ventas');
              },
              child: const Text('Ventas'),
            ),
          ],
        ),
      ),
      drawer: myDrawer(context, _profileImage),
    );
  }

  Widget myDrawer(BuildContext context, String profileImage) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: profileImage.startsWith('assets')
                          ? AssetImage(profileImage)
                          : FileImage(File(profileImage)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nombre del Usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title:
                    const Text('Perfil', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, '/perfil');
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette, color: Colors.white),
                title:
                    const Text('Temas', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, '/temas');
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
            onTap: () async {
              try {
                // Cerrar sesión de Firebase
                await FirebaseAuth.instance.signOut();
                await signOutWithGoogle();

                print('Usuario cerrado sesión exitosamente');

                Navigator.pushReplacementNamed(context, '/login');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sesión cerrada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('Error al cerrar sesión: $e');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al cerrar sesión'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
