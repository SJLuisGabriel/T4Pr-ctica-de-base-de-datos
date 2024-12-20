import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:t4bd/firebase/usuarios_firebase.dart';
import 'package:t4bd/models/events_model.dart';
import 'package:t4bd/settings/ThemeProvider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:t4bd/settings/user_data_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat formato = CalendarFormat.month;
  final Map<DateTime, List<EventsModel>> eventsDay =
      {}; // Almacena los eventos por fecha
  final ValueNotifier<List<EventsModel>> eventsSelected =
      ValueNotifier([]); // Para actualizar la vista cuando cambien los eventos
  final firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    getEvents();
  }

  //Trae la información del usuario y actualiza el provider
  Future<void> fetchUserProfile(String email) async {
    final userData = await firebaseService.getUserByEmail(email);
    Provider.of<UserDataProvider>(context, listen: false)
        .setFoto(userData['foto']);
    Provider.of<UserDataProvider>(context, listen: false)
        .setTelefono(userData['telefono']);
    Provider.of<UserDataProvider>(context, listen: false)
        .setUbicacion(userData['ubicacion']);
    Provider.of<UserDataProvider>(context, listen: false)
        .setEdad(userData['edad']);
  }

  @override
  Widget build(BuildContext context) {
    final correo = Provider.of<UserDataProvider>(context).correo;
    final nombreUsuario = Provider.of<UserDataProvider>(context).nombreUsuario;
    final foto = Provider.of<UserDataProvider>(context).foto;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Animate(
          effects: [
            ShimmerEffect(
              colors: [
                Colors.white,
                Theme.of(context).primaryColor,
              ],
              duration: const Duration(seconds: 2),
            ),
          ],
          child: Builder(
            builder: (context) {
              final themeProvider = Provider.of<ThemeProvider>(context);

              return Text(
                'Inicio',
                style: TextStyle(
                  fontFamily: themeProvider
                      .currentFont, // Usa el font del themeProvider
                ),
              );
            },
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(), // Botón circular
                  padding: const EdgeInsets.all(12), // Tamaño reducido
                ),
                onPressed: () {
                  getEvents();
                },
                child: const Icon(
                  Icons.refresh, // Ícono de recarga
                  size: 24, // Tamaño del ícono
                ),
              ),
            ),
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
              firstDay: DateTime.now().subtract(const Duration(days: 40)),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
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
                  Navigator.pushNamed(context, '/register');
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return Text(
                          'Registrar pedido',
                          style:
                              TextStyle(fontFamily: themeProvider.currentFont),
                        );
                      },
                    ),
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
                  Navigator.pushNamed(context, '/pendientes');
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return Text(
                          'Pedidos pendientes',
                          style:
                              TextStyle(fontFamily: themeProvider.currentFont),
                        );
                      },
                    ),
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
                  Navigator.pushNamed(context, '/historial');
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return Text(
                          'Historial pedidos',
                          style:
                              TextStyle(fontFamily: themeProvider.currentFont),
                        );
                      },
                    ),
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
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: 'Courier New',
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ValueListenableBuilder<List<EventsModel>>(
                    valueListenable: eventsSelected,
                    builder: (context, value, child) {
                      return ListView.separated(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          final event = value[index];
                          return ListTile(
                            title: Text(
                              event.evento,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              event.estatus,
                              style: TextStyle(
                                  color: getStatusColorSubtitle(event.estatus),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            tileColor: getStatusColor(event.estatus),
                          );
                        },
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 5,
                        ),
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

  // Método para obtener los eventos desde Firestore
  void getEvents() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('pedidos').get();
    querySnapshot.docs.forEach(
      (element) {
        DateTime date = element['fecha_agendada'].toDate();
        String event = element['titulo'].toString();
        String estatus = element['estatus'].toString();

        setState(
          () {
            // Si el estatus es "Pendiente", agrega el evento
            if (estatus == 'Pendiente') {
              DateTime normalizedDate = _normalizeDate(date);
              if (eventsDay.containsKey(normalizedDate)) {
                eventsDay[normalizedDate]!.add(EventsModel(event, estatus));
              } else {
                eventsDay[normalizedDate] = [EventsModel(event, estatus)];
              }
            } else {
              // Si el estatus no es "Pendiente", limpia la fecha y el evento
              DateTime normalizedDate = _normalizeDate(date);
              if (eventsDay.containsKey(normalizedDate)) {
                eventsDay[normalizedDate]!
                    .clear(); // Limpia los eventos de esa fecha
              }
            }
          },
        );
      },
    );
    // Actualiza la lista de eventos seleccionados para el día actual
    eventsSelected.value = eventsDay[_normalizeDate(_focusedDay)] ?? [];
  }

  // Normaliza la fecha para compararla correctamente (sin horas, minutos, segundos)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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
                  fetchUserProfile(correo);
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
                  Icons.payment,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'Mis Suscripciones',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/suscripcion');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.playlist_add_check_circle_outlined,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(
                  'Alta productos',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/alta');
                },
              )
            ],
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              try {
                // Obtén el método de autenticación desde tu provider
                final metodo =
                    Provider.of<UserDataProvider>(context, listen: false)
                        .metodo;
                // Llama al método de cierre de sesión dinámico
                await signOutBasedOnMethod(metodo);
                UserDataProvider().resetDatos();
                Navigator.pushReplacementNamed(context, '/login');
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

  Future<void> signOutBasedOnMethod(String metodo) async {
    switch (metodo) {
      case 'Google':
        await signOutWithGoogle();
        break;
      case 'Facebook':
        await signOutWithFacebook();
        break;
      case 'GitHub':
        await signOutWithGitHub();
        break;
      case 'Correo y Contraseña':
        await signOutWithEmailAndPassword();
        break;
      default:
        throw Exception('Método de autenticación desconocido: $metodo');
    }
  }

  Future<void> signOutWithGoogle() async {
    try {
      // Cerrar sesión de Google
      await GoogleSignIn().signOut();
      // Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();
      print('Sesión cerrada de Google y Firebase');
      Navigator.pushReplacementNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al cerrar sesión con Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cerrar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signOutWithFacebook() async {
    try {
      // Cerrar sesión de Facebook
      await FacebookAuth.instance.logOut();
      // Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();
      print('Sesión cerrada de Facebook y Firebase');
      Navigator.pushReplacementNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al cerrar sesión con Facebook: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cerrar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signOutWithGitHub() async {
    try {
      // En caso de manejar un flujo OAuth, podrías invalidar tokens aquí
      // Actualmente no hay API directa para cerrar sesión en GitHub
      // Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();
      print('Sesión cerrada de GitHub y Firebase');
      Navigator.pushReplacementNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al cerrar sesión con GitHub: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cerrar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signOutWithEmailAndPassword() async {
    try {
      // Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();
      print('Sesión cerrada de correo y Firebase');
      Navigator.pushReplacementNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al cerrar sesión con correo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cerrar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
