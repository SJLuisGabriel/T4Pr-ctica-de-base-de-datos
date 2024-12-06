import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:t4bd/firebase/order_firebase.dart';
import 'package:t4bd/models/events_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:t4bd/settings/user_data_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
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
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();

    _selectedDay = focusedDay;
    getEvents();
  }

  @override
  Widget build(BuildContext context) {
    final correo = Provider.of<UserDataProvider>(context).correo;
    final nombreUsuario = Provider.of<UserDataProvider>(context).nombreUsuario;
    final foto = Provider.of<UserDataProvider>(context).foto;

    return Scaffold(
      appBar: AppBar(
        title: Animate(
          effects: [
            ShimmerEffect(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color.fromARGB(255, 255, 255, 255),
                      Theme.of(context).colorScheme.secondary,
                    ]
                  : [
                      const Color.fromARGB(255, 33, 32, 32),
                      Theme.of(context).primaryColor,
                    ],
              duration: const Duration(seconds: 2),
            ),
          ],
          child: const Text(
            'Inicio',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/pendientes');
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Center(
                    child: Text('Pedidos pendientes'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/ventas');
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Center(
                    child: Text('Historial de pedidos'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Center(
                    child: Text('Realizar pedido'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: myDrawer(context, foto, correo, nombreUsuario),
    );
  }

  Widget myDrawer(
      BuildContext context, String foto, String correo, String nombreUsuario) {
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
                    // Mostrar la foto del perfil pasada como parámetro
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.2,
                      backgroundImage: foto.startsWith('http')
                          ? NetworkImage(foto) // Usa NetworkImage para URLs
                          : foto.startsWith('asset')
                              ? AssetImage(
                                  foto) // Usa AssetImage para imágenes de assets
                              : File(foto).existsSync()
                                  ? FileImage(File(foto))
                                      as ImageProvider // Usa FileImage para archivos locales
                                  : const AssetImage(
                                      'assets/perfil2.jpg'), // Imagen por defecto si no se encuentra la foto
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          correo, // Correo pasado como parámetro
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
                          nombreUsuario, // Nombre de usuario pasado como parámetro
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text('Perfil',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    )),
                onTap: () {
                  Navigator.pushNamed(context, '/perfil');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.palette,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text('Temas',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    )),
                onTap: () {
                  Navigator.pushNamed(context, '/temas');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.map, // Icono relacionado con mapas
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'Mapa', // Texto actualizado para reflejar la ruta de los mapas
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  // Navegar a la ruta de Maps
                  Navigator.pushNamed(context, '/maps');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.map, // Icono relacionado con mapas
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'Mapa', // Texto actualizado para reflejar la ruta de los mapas
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  // Navegar a la ruta de Maps
                  Navigator.pushNamed(context, '/suscripcion');
                },
              )
            ],
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'Cerrar sesión',
            ),
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
          ),
        ],
      ),
    );
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
