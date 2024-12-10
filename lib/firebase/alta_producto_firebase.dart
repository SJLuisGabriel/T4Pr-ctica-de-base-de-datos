import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AltaProductoFirebase {
  final CollectionReference _productCollection =
      FirebaseFirestore.instance.collection('productos');
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addProduct({
    required String name,
    String? description,
    String? category,
    required double price,
    required int stock,
    required String imageUrl,
  }) async {
    await _productCollection.add({
      'nombre': name,
      'descripcion': description,
      'categoria': category,
      'precio': price,
      'stock': stock,
      'fecha_agregado': DateTime.now(),
      'imagen_url': imageUrl,
    });
  }

  Future<String> uploadImage(File image) async {
    try {
      final String path =
          'productos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String result =
          await _supabase.storage.from('product-images').upload(path, image);
      return _supabase.storage.from('product-images').getPublicUrl(path);
    } catch (e) {
      log('$e');
      throw Exception('Error al subir la imagen: $e');
    }
  }
}
