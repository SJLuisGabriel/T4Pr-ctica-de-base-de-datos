import 'package:cloud_firestore/cloud_firestore.dart';

class JewelsFirebase {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? jewelsReference;

  JewelsFirebase() {
    jewelsReference = firebaseFirestore.collection("joyas");
  }

  Stream<QuerySnapshot> consultar() {
    return jewelsReference!.snapshots();
  }

  Stream<QuerySnapshot> consultarProductosCategoria(String categoria) {
    return jewelsReference!
        .where('categoria', isEqualTo: categoria)
        .snapshots();
  }

  Stream<QuerySnapshot> consultarPorId(int id) {
    return jewelsReference!.where('id_joya', isEqualTo: id).snapshots();
  }
}
