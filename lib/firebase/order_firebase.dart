import 'package:cloud_firestore/cloud_firestore.dart';

class OrderFirebase {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? orderReference;

  OrderFirebase() {
    orderReference = firebaseFirestore.collection("pedidos");
  }

  Stream<QuerySnapshot> SELECT() {
    return orderReference!.snapshots();
  }

  Future<void> INSERT(Map<String, dynamic> data) async {
    return orderReference!.doc().set(data);
  }

  Future<void> UPDATE(Map<String, dynamic> data, String id) async {
    return orderReference!.doc(id).update(data);
  }

  Future<void> DELETE(String id) async {
    return orderReference!.doc(id).delete();
  }

  Stream<QuerySnapshot> consultarPedidosPendientes() {
    return orderReference!.where('estatus', isEqualTo: 'Pendiente').snapshots();
  }

  //Metodo por si quieres obtener la info de las joyas con su id
  Stream<QuerySnapshot> consultarJoyas(String id) {
    orderReference = firebaseFirestore.collection('joyas');
    return orderReference!.where('id_joya', isEqualTo: id).snapshots();
  }
}
