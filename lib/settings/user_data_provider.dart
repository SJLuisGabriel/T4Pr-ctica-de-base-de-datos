import 'package:flutter/material.dart';

class UserDataProvider extends ChangeNotifier {
  String _correo = '';
  String _metodo = '';
  String _nombreUsuario = '';

  // Getter para acceder
  String get correo => _correo;
  String get metodo => _metodo;
  String get nombreUsuario => _nombreUsuario;

  // Setter para actualizar
  void setCorreo(String correo) {
    _correo = correo;
    notifyListeners(); // Notifica a los widgets que escuchan este cambio
  }

  void setMetodo(String metodo) {
    _metodo = metodo;
    notifyListeners();
  }

  void setNombreUsuario(String nombreUsuario) {
    _nombreUsuario = nombreUsuario;
    notifyListeners();
  }
}
