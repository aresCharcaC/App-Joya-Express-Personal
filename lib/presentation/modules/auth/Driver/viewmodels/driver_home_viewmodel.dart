import 'package:flutter/material.dart';

class Solicitud {
  final String nombre;
  final String foto;
  final double precio;
  final String direccion;
  final List<String> metodos;
  final double rating;
  final int votos;

  Solicitud({
    required this.nombre,
    required this.foto,
    required this.precio,
    required this.direccion,
    required this.metodos,
    required this.rating,
    required this.votos,
  });
}

class Driver {
  final String id;
  final String nombreCompleto;
  final String telefono;

  Driver({
    required this.id,
    required this.nombreCompleto,
    required this.telefono,
  });
}

class DriverHomeViewModel extends ChangeNotifier {
  bool disponible = true;
  List<Solicitud> solicitudes = [];
  Driver? currentDriver;

  void init() {
    // Simula solicitudes cercanas
    solicitudes = [
      Solicitud(
        nombre: 'Mafer',
        foto: 'https://randomuser.me/api/portraits/women/1.jpg',
        precio: 7.5,
        direccion: 'JAC GARAGE & CARS SAC (Avenida la Fontana, La Molina)',
        metodos: ['Yape', 'Efectivo'],
        rating: 4.77,
        votos: 35,
      ),
      Solicitud(
        nombre: 'Anthony',
        foto: 'https://randomuser.me/api/portraits/men/2.jpg',
        precio: 7.5,
        direccion: 'JAC GARAGE & CARS SAC (Avenida la Fontana, La Molina)',
        metodos: ['Plin', 'Yape', 'Efectivo'],
        rating: 4.77,
        votos: 35,
      ),
      Solicitud(
        nombre: 'Luis',
        foto: 'https://randomuser.me/api/portraits/men/3.jpg',
        precio: 8.0,
        direccion: 'JAC GARAGE & CARS SAC (Avenida la Fontana, La Molina)',
        metodos: ['Yape', 'Plin'],
        rating: 4.77,
        votos: 35,
      ),
    ];
    // Simula datos del conductor actual
    currentDriver = Driver(
      id: '1',
      nombreCompleto: 'Luis Pérez',
      telefono: '987654321',
    );
    notifyListeners();
  }

  void setDisponible(bool value) {
    disponible = value;
    notifyListeners();
  }
}