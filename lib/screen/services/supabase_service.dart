import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  Future<String?> uploadProfileImage(String userId, String filePath) async {
    try {
      final fileName =
          '$userId/profile-${DateTime.now().millisecondsSinceEpoch}.jpg';

      final response = await client.storage
          .from('storage_img&vids')
          .upload(fileName, File(filePath));

      // Verificar si la respuesta contiene un mensaje de error
      if (response.startsWith('Error:')) {
        throw Exception('Error uploading image: $response');
      }

      // Obtener la URL pública si la carga fue exitosa
      final publicUrl =
          client.storage.from('storage_img&vids').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }
}
