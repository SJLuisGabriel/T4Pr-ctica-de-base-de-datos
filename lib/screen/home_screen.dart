import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:t4bd/firebase/order_firebase.dart';
import 'package:t4bd/models/events_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:t4bd/settings/user_data_provider.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class RandomNameGenerator {
  String? _generatedName; // Almacena el nombre generado
  bool _isNameGenerated = false; // Bandera para saber si ya se generó el nombre

  // Método para generar el nombre aleatorio solo una vez
  Future<String> generateRandomName() async {
    // Si ya se generó un nombre, devolverlo sin volver a generarlo
    if (_isNameGenerated) {
      return _generatedName!;
    }

    // Si no se generó, generamos el nombre aleatorio
    const characters = 'abcdefghijklmnopqrstuvwxyz';
    final random = Random();

    // Generar un nombre aleatorio de hasta 6 caracteres
    String name = '';
    int nameLength =
        random.nextInt(6) + 1; // La longitud del nombre será entre 1 y 6

    for (int i = 0; i < nameLength; i++) {
      name += characters[random.nextInt(characters.length)];
    }

    // Generar 3 dígitos aleatorios
    String digits = '';
    for (int i = 0; i < 3; i++) {
      digits += random.nextInt(10).toString(); // Genera números entre 0 y 9
    }

    // Combinar el nombre con los dígitos aleatorios
    _generatedName = '$name$digits';
    _isNameGenerated = true; // Establecer la bandera a true

    return _generatedName!; // Retornar el nombre generado
  }

  // Método para resetear la generación del nombre si es necesario (opcional)
  void resetNameGeneration() {
    _isNameGenerated = false;
    _generatedName = null;
  }
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat formato = CalendarFormat.month;
  final Map<DateTime, List<EventsModel>> eventsDay =
      {}; // Almacena los eventos por fecha
  final ValueNotifier<List<EventsModel>> eventsSelected =
      ValueNotifier([]); // Para actualizar la vista cuando cambien los eventos
  final pedidos = OrderFirebase();
  String _profileImage = 'assets/perfil1.jpg'; // Imagen por defecto
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    _generateAndSaveName(context);
    super.initState();

    _selectedDay = focusedDay;
    getEvents();
    _loadProfileImage(); // Cargar la imagen al iniciar
  }

  // Método para generar y guardar el nombre
  Future<void> _generateAndSaveName(BuildContext context) async {
    String randomName = await RandomNameGenerator().generateRandomName();

    // Guardar el nombre generado en el UserDataProvider
    Provider.of<UserDataProvider>(context, listen: false)
        .setNombreUsuario(randomName);
  }

  @override
  Widget build(BuildContext context) {
    final correo = Provider.of<UserDataProvider>(context).correo;

    final nombreUsuario = Provider.of<UserDataProvider>(context).nombreUsuario;

    return Scaffold(
      appBar: AppBar(
        title: Animate(
          effects: [
            ShimmerEffect(
              colors: [
                const Color.fromARGB(255, 255, 255, 255),
                Theme.of(context).primaryColor
              ],
              duration: const Duration(seconds: 2),
            )
          ],
          child: Text(
            'Inicio',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            TableCalendar(
              headerStyle: const HeaderStyle(titleCentered: true),
              availableCalendarFormats: const {
                CalendarFormat.month: '1 semana',
                CalendarFormat.twoWeeks: 'Mes',
                CalendarFormat.week: '2 semanas',
              },
              calendarFormat: formato,
              onFormatChanged: (format) {
                if (formato != format) {
                  setState(() {
                    formato = format;
                  });
                }
              },
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  focusedDay = focusedDay;
                });
                _showEventsForDay(selectedDay);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  // Si hay eventos pendientes para este día, mostrar un punto
                  if (eventsDay[_normalizeDate(day)]
                          ?.any((e) => e.estatus == 'Pendiente') ??
                      false) {
                    return Positioned(
                      bottom: 8,
                      right: 24,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red, // El color del punto
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return const SizedBox(); // Si no hay eventos, no se muestra nada
                },
                defaultBuilder: (context, day, focusedDay) {
                  final dayEvents = eventsDay[day] ?? [];
                  Color pointColor;

                  if (dayEvents.isEmpty) {
                    pointColor = Colors.transparent; // Sin eventos
                  } else if (dayEvents
                      .any((event) => event.estatus == 'Cancelado')) {
                    pointColor = Colors.red; // Al menos un cancelado
                  } else if (dayEvents
                      .any((event) => event.estatus == 'Pendiente')) {
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
              child: SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.8, // Ocupa el 80% del ancho de la pantalla
                child: const Center(
                  child: Text('Pedidos pendientes'),
                ),
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
                Navigator.pushNamed(context, '/ventas');
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.8, // Ocupa el 80% del ancho de la pantalla
                child: const Center(
                  child: Text('Historial de pedidos'),
                ),
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
                Navigator.pushNamed(context, '/register');
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.8, // Ocupa el 80% del ancho de la pantalla
                child: const Center(
                  child: Text('Realizar pedido'),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: myDrawer(context, _profileImage, correo, nombreUsuario),
    );
  }

  Widget myDrawer(BuildContext context, String profileImage, String correo,
      String nombreUsuario) {
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          correo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          nombreUsuario,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
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
                  const SnackBar(
                    content: Text('Sesión cerrada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('Error al cerrar sesión: $e');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
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

  // Función para guardar la imagen seleccionada en SharedPreferences
  void _saveProfileImage(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profileImage', imagePath);
    setState(() {
      _profileImage = imagePath;
    });
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

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.amber; // Por cumplir
      case 'Cancelado':
        return Colors.red; // Cancelado
      case 'Completado':
        return Colors.green; // Completado
      default:
        return Colors.grey; // Por defecto
    }
  }

  Color getStatusColorSubtitle(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.red; // Por cumplir
      case 'Cancelado':
        return Colors.amber; // Cancelado
      case 'Completado':
        return Colors.grey; // Completado
      default:
        return Colors.green; // Por defecto
    }
  }

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
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');

      // Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cerrar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Normaliza la fecha para compararla correctamente (sin horas, minutos, segundos)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Método para obtener los eventos desde Firestore
  void getEvents() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('pedidos').get();
    querySnapshot.docs.forEach((element) {
      DateTime date = DateTime.parse(element['fecha_agendada']);
      String event = element['titulo'].toString();
      String estatus = element['estatus'].toString();

      setState(() {
        if (estatus == 'Pendiente') {
          DateTime normalizedDate = _normalizeDate(date);
          if (eventsDay.containsKey(normalizedDate)) {
            eventsDay[normalizedDate]!.add(EventsModel(event, estatus));
          } else {
            eventsDay[normalizedDate] = [EventsModel(event, estatus)];
          }
        }
      });
    });

    // Actualiza la lista de eventos seleccionados para el día actual
    eventsSelected.value = eventsDay[_normalizeDate(focusedDay)] ?? [];
  }

  // Método para mostrar los eventos del día seleccionado
  void _showEventsForDay(DateTime day) {
    final dayEvents = eventsDay[_normalizeDate(day)] ?? [];

    // Si no hay eventos para el día seleccionado, muestra un mensaje
    if (dayEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No hay eventos para este día"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Actualiza los eventos seleccionados para el día
      eventsSelected.value = dayEvents;
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
                  child: ValueListenableBuilder<List<EventsModel>>(
                    valueListenable: eventsSelected,
                    builder: (context, value, child) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          final event = value[index];
                          return ListTile(
                            title: Text(
                              event.evento,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface),
                            ),
                            subtitle: Text(
                              '${event.estatus}',
                              style: TextStyle(
                                  color: getStatusColorSubtitle(event.estatus),
                                  fontWeight: FontWeight.bold),
                            ),
                            tileColor: getStatusColor(event.estatus),
                          );
                        },
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
  }
}
