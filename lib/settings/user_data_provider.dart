import 'dart:ffi';

import 'package:flutter/material.dart';

class UserDataProvider extends ChangeNotifier {
  String _correo = '';
  String _metodo = '';
  String _nombreUsuario = '';
  String _foto = '';
  int _edad = 0;
  String _ubicacion = '';
  String _fechaNacimiento = '';
  String _telefono = '';
  String _suscripcion = '';

  // Getters para acceder
  String get correo => _correo;
  String get metodo => _metodo;
  String get nombreUsuario => _nombreUsuario;
  String get foto => _foto;
  int get edad => _edad;
  String get ubicacion => _ubicacion;
  String get fechaNacimiento => _fechaNacimiento;
  String get telefono => _telefono;
  String get suscripcion => _suscripcion;

  // Setters para actualizar
  void setCorreo(String correo) {
    _correo = correo;
    notifyListeners();
  }

  void setMetodo(String metodo) {
    _metodo = metodo;
    notifyListeners();
  }

  void setNombreUsuario(String nombreUsuario) {
    _nombreUsuario = nombreUsuario;
    notifyListeners();
  }

  void setFoto(String foto) {
    _foto = foto;
    notifyListeners();
  }

  void setEdad(int edad) {
    _edad = edad;
    notifyListeners();
  }

  void setUbicacion(String ubicacion) {
    _ubicacion = ubicacion;
    notifyListeners();
  }

  void setFechaNacimiento(String fechaNacimiento) {
    _fechaNacimiento = fechaNacimiento;
    notifyListeners();
  }

  void setTelefono(String telefono) {
    _telefono = telefono;
    notifyListeners();
  }

  void setSuscripcion(String suscripcion) {
    _suscripcion = suscripcion;
    notifyListeners();
  }
}
