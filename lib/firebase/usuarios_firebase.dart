import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Agregar un nuevo documento a la colección
  Future<void> addUser({
    String? correo,
    int? edad,
    String? foto,
    String? telefono,
    String? ubicacion,
    String? registro,
    String? suscripcion,
    DateTime? createdAt,
    String? nombre,
  }) async {
    try {
      await _firestore.collection('usuarios').add({
        'correo': correo ?? "",
        'edad': edad ?? 0,
        'foto': foto ?? "",
        'telefono': telefono ?? "",
        'ubicacion': ubicacion ?? "",
        'registro': registro ?? "",
        'createdAt': createdAt ?? "",
        'suscripcion': suscripcion ?? "",
        'nombre': nombre ?? "",
      });
      print("Usuario agregado con éxito.");
    } catch (e) {
      print("Error al agregar el usuario: $e");
    }
  }

  // Obtener todos los usuarios
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error al obtener los usuarios: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('usuarios') // Cambia 'users' al nombre de tu colección
          .where('correo', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  Future<void> updateUserByEmail(
      String email, Map<String, dynamic> updatedData) async {
    try {
      // Busca el documento por correo
      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('correo', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        // Actualiza el documento
        await _firestore.collection('usuarios').doc(docId).update(updatedData);
        print("Usuario actualizado con éxito.");
      } else {
        print("No se encontró un usuario con ese correo.");
      }
    } catch (e) {
      print("Error al actualizar el usuario: $e");
    }
  }

  Future<void> updateSuscripcionByEmail(
      String email, String suscripcion) async {
    try {
      // Busca el documento por correo
      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('correo', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        // Crea un mapa con solo el campo 'suscripcion'
        final updatedData = {'suscripcion': suscripcion};

        // Actualiza el campo 'suscripcion' del documento
        await _firestore.collection('usuarios').doc(docId).update(updatedData);
        print("Suscripción actualizada con éxito.");
      } else {
        print("No se encontró un usuario con ese correo.");
      }
    } catch (e) {
      print("Error al actualizar la suscripción: $e");
    }
  }
}
