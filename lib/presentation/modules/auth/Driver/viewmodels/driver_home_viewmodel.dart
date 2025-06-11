// lib/presentation/modules/auth/Driver/viewmodels/driver_home_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../data/services/rides_service.dart';
import '../../../../../data/services/websocket_service.dart';
import '../../../../../data/models/ride_request_model.dart';
import 'dart:math';

class DriverHomeViewModel extends ChangeNotifier {
  final RidesService _ridesService = RidesService();
  final WebSocketService _wsService = WebSocketService();

  // Estado del conductor
  bool _disponible = false;
  bool _isLoadingSolicitudes = false;
  String? _error;

  // Datos
  List<dynamic> _solicitudes = [];
  Driver? _currentDriver;

  // Timers para actualizaciones automáticas
  Timer? _locationTimer;
  Timer? _requestsTimer;
  Timer? _pingTimer;

  // Ubicación actual
  Position? _currentPosition;

  // Getters
  bool get disponible => _disponible;
  bool get isLoadingSolicitudes => _isLoadingSolicitudes;
  String? get error => _error;
  List<dynamic> get solicitudes => _solicitudes;
  Driver? get currentDriver => _currentDriver;
  Position? get currentPosition => _currentPosition;

  /// 🚀 Inicializar con servicios reales + mocks
  Future<void> init({String? conductorId, String? token}) async {
    print('🚀 Inicializando DriverHomeViewModel...');

    try {
      // Simular datos del conductor actual
      _currentDriver = Driver(
        id: conductorId ?? '1',
        nombreCompleto: 'Luis Pérez',
        telefono: '987654321',
      );

      // Obtener ubicación inicial
      await _initializeLocation();

      // Conectar WebSocket si hay datos de autenticación
      if (conductorId != null && token != null) {
        await _connectWebSocket(conductorId, token);
      }

      // Cargar solicitudes iniciales (combinar real + mocks)
      await _loadInitialRequests();

      print('✅ DriverHomeViewModel inicializado');
    } catch (e) {
      print('❌ Error inicializando DriverHomeViewModel: $e');
      _error = 'Error al inicializar: $e';
    }

    notifyListeners();
  }

  /// 📍 Inicializar ubicación GPS
  Future<void> _initializeLocation() async {
    try {
      _currentPosition = await _ridesService.getCurrentLocation();
      if (_currentPosition != null) {
        print(
          '📍 Ubicación inicial: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
        );
      }
    } catch (e) {
      print('❌ Error obteniendo ubicación inicial: $e');
    }
  }

  /// 🔌 Conectar WebSocket
  Future<void> _connectWebSocket(String conductorId, String token) async {
    try {
      final connected = await _wsService.connectDriver(conductorId, token);

      if (connected) {
        // Registrar eventos
        _wsService.onEvent('ride:new', _handleNewRideRequest);
        _wsService.onEvent('ride:offer_accepted', _handleOfferAccepted);
        _wsService.onEvent('ride:cancelled', _handleRideCancelled);

        // Ping cada 30 segundos para mantener conexión
        _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
          _wsService.ping();
        });

        print('✅ WebSocket configurado correctamente');
      }
    } catch (e) {
      print('❌ Error conectando WebSocket: $e');
    }
  }

  /// 🆕 Manejar nueva solicitud por WebSocket
  void _handleNewRideRequest(Map<String, dynamic> data) {
    print('🆕 Nueva solicitud recibida por WebSocket');

    try {
      // Convertir datos WebSocket a modelo
      final request = RideRequestModel.fromJson(data['ride'] ?? data);
      final mockRequest = request.toMockFormat();

      // Agregar a la lista si no existe
      final exists = _solicitudes.any((s) => s.rideId == request.id);
      if (!exists) {
        _solicitudes.insert(0, mockRequest); // Agregar al inicio
        notifyListeners();
        print('✅ Solicitud agregada a la lista');
      }
    } catch (e) {
      print('❌ Error procesando nueva solicitud: $e');
    }
  }

  /// ✅ Manejar oferta aceptada
  void _handleOfferAccepted(Map<String, dynamic> data) {
    print('✅ Oferta aceptada: ${data['rideId']}');
    // TODO: Navegar a pantalla de viaje activo
  }

  /// ❌ Manejar viaje cancelado
  void _handleRideCancelled(Map<String, dynamic> data) {
    print('❌ Viaje cancelado: ${data['rideId']}');

    // Remover de la lista
    _solicitudes.removeWhere((s) => s.rideId == data['rideId']);
    notifyListeners();
  }

  /// 📋 Cargar solicitudes iniciales (real + mocks)
  Future<void> _loadInitialRequests() async {
    _isLoadingSolicitudes = true;
    notifyListeners();

    try {
      List<dynamic> allRequests = [];

      // 1. Asegurar que tenemos ubicación actualizada en el backend
      if (_currentPosition != null) {
        try {
          await _ridesService.updateDriverLocation(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
          print(
            '✅ Ubicación actualizada en backend antes de buscar solicitudes',
          );
        } catch (e) {
          print('⚠️ Error actualizando ubicación: $e');
        }
      }

      // 2. Intentar cargar solicitudes reales del backend
      try {
        final realRequests = await _ridesService.getNearbyRequests();
        final mockRequests = realRequests.map((r) => r.toMockFormat()).toList();
        allRequests.addAll(mockRequests);
        print('✅ ${realRequests.length} solicitudes reales cargadas');
      } catch (e) {
        print('⚠️ No se pudieron cargar solicitudes reales: $e');
      }

      // 3. Siempre agregar mocks (ahora son 20)
      final mockSolicitudes = _generateMockRequests();
      allRequests.addAll(mockSolicitudes);
      print('✅ ${mockSolicitudes.length} solicitudes mock agregadas');

      // 4. ✅ FILTRAR POR DISTANCIA (7 cuadras ≈ 700-800 metros)
      if (_currentPosition != null) {
        final solicitudesFiltradas = _filterByDistance(
          allRequests,
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          800.0, // 800 metros = ~7-8 cuadras
        );

        _solicitudes = solicitudesFiltradas;
        print(
          '🔍 Filtrado: ${solicitudesFiltradas.length} de ${allRequests.length} solicitudes mostradas',
        );
      } else {
        // Si no hay ubicación, mostrar todas
        _solicitudes = allRequests;
        print(
          '⚠️ Sin ubicación del conductor, mostrando todas las solicitudes',
        );
      }

      _error = null;
    } catch (e) {
      print('❌ Error cargando solicitudes: $e');
      _error = 'Error cargando solicitudes: $e';

      // Fallback a solo mocks sin filtrar
      _solicitudes = _generateMockRequests();
    }

    _isLoadingSolicitudes = false;
    notifyListeners();
  }

  /// 🔍 Filtrar solicitudes por distancia desde la ubicación del conductor
  List<dynamic> _filterByDistance(
    List<dynamic> solicitudes,
    double conductorLat,
    double conductorLng,
    double maxDistanceMeters,
  ) {
    final List<dynamic> solicitudesCercanas = [];

    for (final solicitud in solicitudes) {
      try {
        // Obtener coordenadas del origen de la solicitud
        double origenLat;
        double origenLng;

        if (solicitud is MockSolicitud) {
          origenLat = solicitud.origenLat;
          origenLng = solicitud.origenLng;
        } else {
          // Para solicitudes reales del backend
          origenLat = solicitud['origenLat'] ?? solicitud['origen_lat'] ?? 0.0;
          origenLng = solicitud['origenLng'] ?? solicitud['origen_lng'] ?? 0.0;
        }

        // Calcular distancia usando fórmula Haversine
        final distanceMeters = _calculateHaversineDistance(
          conductorLat,
          conductorLng,
          origenLat,
          origenLng,
        );

        // Solo agregar si está dentro del radio
        if (distanceMeters <= maxDistanceMeters) {
          solicitudesCercanas.add(solicitud);
          print(
            '✅ Solicitud ${solicitud is MockSolicitud ? solicitud.rideId : solicitud['id']} agregada - ${distanceMeters.round()}m',
          );
        } else {
          print(
            '❌ Solicitud ${solicitud is MockSolicitud ? solicitud.rideId : solicitud['id']} filtrada - ${distanceMeters.round()}m (muy lejos)',
          );
        }
      } catch (e) {
        print('⚠️ Error calculando distancia para solicitud: $e');
        // En caso de error, incluir la solicitud por seguridad
        solicitudesCercanas.add(solicitud);
      }
    }

    return solicitudesCercanas;
  }

  /// 📐 Calcular distancia Haversine entre dos puntos (en metros)
  double _calculateHaversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadiusKm = 6371;

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);

    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distanceKm = earthRadiusKm * c;

    return distanceKm * 1000; // Convertir a metros
  }

  /// 🔢 Convertir grados a radianes
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// 🎭 Generar solicitudes mock para desarrollo
  List<dynamic> _generateMockRequests() {
    return [
      // ===== 5 MOCKS ALREDEDOR DE UBICACIÓN 1 (-16.407969, -71.481970) =====
      MockSolicitud(
        rideId: 'mock_1',
        usuarioId: 'user_1',
        nombre: 'María',
        foto: 'https://randomuser.me/api/portraits/women/1.jpg',
        precio: 8.5,
        direccion: 'Av. Ejército 850, Yanahuara',
        metodos: ['Yape', 'Efectivo'],
        rating: 4.8,
        votos: 45,
        origenLat: -16.405234,
        origenLng: -71.482156,
        destinoDireccion: 'Plaza de Armas de Arequipa',
        destinoLat: -16.398866,
        destinoLng: -71.536985,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 2)),
        distanciaKm: 2.1,
        tiempoEstimadoMinutos: 12,
      ),
      MockSolicitud(
        rideId: 'mock_2',
        usuarioId: 'user_2',
        nombre: 'Carlos',
        foto: 'https://randomuser.me/api/portraits/men/2.jpg',
        precio: 7.0,
        direccion: 'Calle Ugarte 230, Yanahuara',
        metodos: ['Plin', 'Yape'],
        rating: 4.6,
        votos: 32,
        origenLat: -16.409876,
        origenLng: -71.480432,
        destinoDireccion: 'Mall Aventura Plaza',
        destinoLat: -16.432089,
        destinoLng: -71.509876,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 5)),
        distanciaKm: 3.8,
        tiempoEstimadoMinutos: 18,
      ),
      MockSolicitud(
        rideId: 'mock_3',
        usuarioId: 'user_3',
        nombre: 'Ana',
        foto: 'https://randomuser.me/api/portraits/women/3.jpg',
        precio: 6.5,
        direccion: 'Av. Lima 450, Yanahuara',
        metodos: ['Efectivo'],
        rating: 4.9,
        votos: 67,
        origenLat: -16.406123,
        origenLng: -71.483789,
        destinoDireccion: 'Universidad Nacional San Agustín',
        destinoLat: -16.403045,
        destinoLng: -71.529012,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 8)),
        distanciaKm: 2.9,
        tiempoEstimadoMinutos: 15,
      ),
      MockSolicitud(
        rideId: 'mock_4',
        usuarioId: 'user_4',
        nombre: 'Diego',
        foto: 'https://randomuser.me/api/portraits/men/4.jpg',
        precio: 9.0,
        direccion: 'Calle Jerusalem 180, Yanahuara',
        metodos: ['Yape', 'Plin', 'Efectivo'],
        rating: 4.7,
        votos: 28,
        origenLat: -16.410567,
        origenLng: -71.479823,
        destinoDireccion: 'Terminal Terrestre',
        destinoLat: -16.415034,
        destinoLng: -71.532145,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 12)),
        distanciaKm: 4.2,
        tiempoEstimadoMinutos: 20,
      ),
      MockSolicitud(
        rideId: 'mock_5',
        usuarioId: 'user_5',
        nombre: 'Lucía',
        foto: 'https://randomuser.me/api/portraits/women/5.jpg',
        precio: 7.5,
        direccion: 'Av. Venezuela 320, Yanahuara',
        metodos: ['Yape'],
        rating: 4.5,
        votos: 19,
        origenLat: -16.408234,
        origenLng: -71.481567,
        destinoDireccion: 'Hospital Nacional Carlos Alberto Seguín',
        destinoLat: -16.385467,
        destinoLng: -71.546789,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 15)),
        distanciaKm: 3.1,
        tiempoEstimadoMinutos: 16,
      ),

      // ===== 7 MOCKS ALREDEDOR DE UBICACIÓN 2 (-16.430271, -71.518973) =====
      MockSolicitud(
        rideId: 'mock_6',
        usuarioId: 'user_6',
        nombre: 'Roberto',
        foto: 'https://randomuser.me/api/portraits/men/6.jpg',
        precio: 8.0,
        direccion: 'Av. Dolores 890, José Luis Bustamante',
        metodos: ['Plin', 'Efectivo'],
        rating: 4.8,
        votos: 56,
        origenLat: -16.428456,
        origenLng: -71.517234,
        destinoDireccion: 'Parque Lambramani',
        destinoLat: -16.422345,
        destinoLng: -71.530123,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 3)),
        distanciaKm: 1.8,
        tiempoEstimadoMinutos: 10,
      ),
      MockSolicitud(
        rideId: 'mock_7',
        usuarioId: 'user_7',
        nombre: 'Patricia',
        foto: 'https://randomuser.me/api/portraits/women/7.jpg',
        precio: 10.0,
        direccion: 'Calle Paucarpata 567, José Luis Bustamante',
        metodos: ['Yape', 'Plin'],
        rating: 4.9,
        votos: 78,
        origenLat: -16.432145,
        origenLng: -71.520456,
        destinoDireccion: 'Aeropuerto Alfredo Rodríguez Ballón',
        destinoLat: -16.341234,
        destinoLng: -71.583456,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 6)),
        distanciaKm: 12.5,
        tiempoEstimadoMinutos: 35,
      ),
      MockSolicitud(
        rideId: 'mock_8',
        usuarioId: 'user_8',
        nombre: 'Fernando',
        foto: 'https://randomuser.me/api/portraits/men/8.jpg',
        precio: 6.0,
        direccion: 'Av. Bustamante 234, José Luis Bustamante',
        metodos: ['Efectivo'],
        rating: 4.4,
        votos: 23,
        origenLat: -16.431789,
        origenLng: -71.516789,
        destinoDireccion: 'Centro Comercial Real Plaza',
        destinoLat: -16.409567,
        destinoLng: -71.538123,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 9)),
        distanciaKm: 2.7,
        tiempoEstimadoMinutos: 14,
      ),
      MockSolicitud(
        rideId: 'mock_9',
        usuarioId: 'user_9',
        nombre: 'Carmen',
        foto: 'https://randomuser.me/api/portraits/women/9.jpg',
        precio: 7.5,
        direccion: 'Calle Los Incas 456, José Luis Bustamante',
        metodos: ['Yape', 'Efectivo'],
        rating: 4.6,
        votos: 34,
        origenLat: -16.428967,
        origenLng: -71.519234,
        destinoDireccion: 'Mercado San Camilo',
        destinoLat: -16.399123,
        destinoLng: -71.537456,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 11)),
        distanciaKm: 3.4,
        tiempoEstimadoMinutos: 17,
      ),
      MockSolicitud(
        rideId: 'mock_10',
        usuarioId: 'user_10',
        nombre: 'Manuel',
        foto: 'https://randomuser.me/api/portraits/men/10.jpg',
        precio: 9.5,
        direccion: 'Av. Victor Andrés Belaunde 789, José Luis Bustamante',
        metodos: ['Plin'],
        rating: 4.7,
        votos: 41,
        origenLat: -16.433456,
        origenLng: -71.517890,
        destinoDireccion: 'Clínica Arequipa',
        destinoLat: -16.405678,
        destinoLng: -71.535234,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 14)),
        distanciaKm: 3.2,
        tiempoEstimadoMinutos: 16,
      ),
      MockSolicitud(
        rideId: 'mock_11',
        usuarioId: 'user_11',
        nombre: 'Sofia',
        foto: 'https://randomuser.me/api/portraits/women/11.jpg',
        precio: 8.5,
        direccion: 'Calle Mariano Melgar 123, José Luis Bustamante',
        metodos: ['Yape', 'Plin', 'Efectivo'],
        rating: 4.8,
        votos: 52,
        origenLat: -16.429234,
        origenLng: -71.521456,
        destinoDireccion: 'Universidad Católica de Santa María',
        destinoLat: -16.434567,
        destinoLng: -71.549123,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 17)),
        distanciaKm: 2.3,
        tiempoEstimadoMinutos: 12,
      ),
      MockSolicitud(
        rideId: 'mock_12',
        usuarioId: 'user_12',
        nombre: 'Jorge',
        foto: 'https://randomuser.me/api/portraits/men/12.jpg',
        precio: 11.0,
        direccion: 'Av. Fernandini 567, José Luis Bustamante',
        metodos: ['Yape'],
        rating: 4.9,
        votos: 63,
        origenLat: -16.431567,
        origenLng: -71.520789,
        destinoDireccion: 'Estadio Melgar',
        destinoLat: -16.456789,
        destinoLng: -71.512345,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 20)),
        distanciaKm: 4.1,
        tiempoEstimadoMinutos: 19,
      ),

      // ===== 8 MOCKS DISTRIBUIDOS POR OTRAS ZONAS DE AREQUIPA =====
      MockSolicitud(
        rideId: 'mock_13',
        usuarioId: 'user_13',
        nombre: 'Elena',
        foto: 'https://randomuser.me/api/portraits/women/13.jpg',
        precio: 12.0,
        direccion: 'Av. Salaverry 890, Cercado',
        metodos: ['Plin', 'Efectivo'],
        rating: 4.7,
        votos: 38,
        origenLat: -16.395678,
        origenLng: -71.535123,
        destinoDireccion: 'Cayma',
        destinoLat: -16.365234,
        destinoLng: -71.548976,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 25)),
        distanciaKm: 5.2,
        tiempoEstimadoMinutos: 22,
      ),
      MockSolicitud(
        rideId: 'mock_14',
        usuarioId: 'user_14',
        nombre: 'Ricardo',
        foto: 'https://randomuser.me/api/portraits/men/14.jpg',
        precio: 5.5,
        direccion: 'Calle Mercaderes 234, Cercado',
        metodos: ['Efectivo'],
        rating: 4.3,
        votos: 16,
        origenLat: -16.398234,
        origenLng: -71.537456,
        destinoDireccion: 'Selva Alegre',
        destinoLat: -16.383456,
        destinoLng: -71.541789,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 28)),
        distanciaKm: 1.9,
        tiempoEstimadoMinutos: 11,
      ),
      MockSolicitud(
        rideId: 'mock_15',
        usuarioId: 'user_15',
        nombre: 'Valeria',
        foto: 'https://randomuser.me/api/portraits/women/15.jpg',
        precio: 13.5,
        direccion: 'Av. Goyeneche 456, Cercado',
        metodos: ['Yape', 'Plin'],
        rating: 4.8,
        votos: 71,
        origenLat: -16.401234,
        origenLng: -71.533789,
        destinoDireccion: 'Paucarpata',
        destinoLat: -16.428976,
        destinoLng: -71.498234,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 30)),
        distanciaKm: 4.8,
        tiempoEstimadoMinutos: 21,
      ),
      MockSolicitud(
        rideId: 'mock_16',
        usuarioId: 'user_16',
        nombre: 'Andrés',
        foto: 'https://randomuser.me/api/portraits/men/16.jpg',
        precio: 9.0,
        direccion: 'Calle San José 789, Cercado',
        metodos: ['Plin'],
        rating: 4.5,
        votos: 25,
        origenLat: -16.402456,
        origenLng: -71.539123,
        destinoDireccion: 'Hunter',
        destinoLat: -16.445678,
        destinoLng: -71.523456,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 33)),
        distanciaKm: 5.1,
        tiempoEstimadoMinutos: 23,
      ),
      MockSolicitud(
        rideId: 'mock_17',
        usuarioId: 'user_17',
        nombre: 'Gabriela',
        foto: 'https://randomuser.me/api/portraits/women/17.jpg',
        precio: 6.5,
        direccion: 'Av. Bolognesi 123, Cercado',
        metodos: ['Yape', 'Efectivo'],
        rating: 4.6,
        votos: 29,
        origenLat: -16.405789,
        origenLng: -71.541456,
        destinoDireccion: 'Mariano Melgar',
        destinoLat: -16.418234,
        destinoLng: -71.525789,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 35)),
        distanciaKm: 2.4,
        tiempoEstimadoMinutos: 13,
      ),
      MockSolicitud(
        rideId: 'mock_18',
        usuarioId: 'user_18',
        nombre: 'Óscar',
        foto: 'https://randomuser.me/api/portraits/men/18.jpg',
        precio: 14.0,
        direccion: 'Calle La Merced 567, Cercado',
        metodos: ['Yape', 'Plin', 'Efectivo'],
        rating: 4.9,
        votos: 84,
        origenLat: -16.399567,
        origenLng: -71.536234,
        destinoDireccion: 'Sachaca',
        destinoLat: -16.432145,
        destinoLng: -71.567890,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 38)),
        distanciaKm: 4.7,
        tiempoEstimadoMinutos: 20,
      ),
      MockSolicitud(
        rideId: 'mock_19',
        usuarioId: 'user_19',
        nombre: 'Isabella',
        foto: 'https://randomuser.me/api/portraits/women/19.jpg',
        precio: 10.5,
        direccion: 'Av. Siglo XX 890, Miraflores',
        metodos: ['Plin'],
        rating: 4.7,
        votos: 47,
        origenLat: -16.425678,
        origenLng: -71.503456,
        destinoDireccion: 'Alto Selva Alegre',
        destinoLat: -16.376789,
        destinoLng: -71.535123,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 40)),
        distanciaKm: 6.3,
        tiempoEstimadoMinutos: 26,
      ),
      MockSolicitud(
        rideId: 'mock_20',
        usuarioId: 'user_20',
        nombre: 'Emilio',
        foto: 'https://randomuser.me/api/portraits/men/20.jpg',
        precio: 8.0,
        direccion: 'Calle Consuelo 234, Miraflores',
        metodos: ['Yape', 'Efectivo'],
        rating: 4.4,
        votos: 31,
        origenLat: -16.427890,
        origenLng: -71.501234,
        destinoDireccion: 'Tiabaya',
        destinoLat: -16.458123,
        destinoLng: -71.493456,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 42)),
        distanciaKm: 3.6,
        tiempoEstimadoMinutos: 18,
      ),
    ];
  }

  /// 🔄 Cambiar disponibilidad del conductor
  Future<void> setDisponible(bool value) async {
    final oldValue = _disponible;
    _disponible = value;
    notifyListeners();

    try {
      if (_disponible) {
        await _startLocationUpdates();
        _startRequestsPolling(); // ✅ SIN await porque es void
        print('✅ Conductor disponible - Servicios iniciados');
      } else {
        _stopLocationUpdates();
        _stopRequestsPolling();
        print('⏹️ Conductor no disponible - Servicios detenidos');
      }
    } catch (e) {
      print('❌ Error cambiando disponibilidad: $e');
      // Revertir cambio en caso de error
      _disponible = oldValue;
      notifyListeners();
    }
  }

  /// 📍 Iniciar actualizaciones automáticas de ubicación
  Future<void> _startLocationUpdates() async {
    _locationTimer?.cancel();

    _locationTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final position = await _ridesService.getCurrentLocation();
        if (position != null) {
          _currentPosition = position;

          // Actualizar en backend
          await _ridesService.updateDriverLocation(
            position.latitude,
            position.longitude,
          );

          // Enviar por WebSocket
          if (_wsService.isConnected) {
            _wsService.sendLocationUpdate(
              position.latitude,
              position.longitude,
            );
          }

          print(
            '📍 Ubicación actualizada: ${position.latitude}, ${position.longitude}',
          );
        }
      } catch (e) {
        print('❌ Error actualizando ubicación: $e');
      }
    });
  }

  /// 🔄 Iniciar polling de solicitudes
  void _startRequestsPolling() {
    _requestsTimer?.cancel();

    _requestsTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await refreshSolicitudes();
    });
  }

  /// ⏹️ Detener actualizaciones de ubicación
  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  /// ⏹️ Detener polling de solicitudes
  void _stopRequestsPolling() {
    _requestsTimer?.cancel();
    _requestsTimer = null;
  }

  /// 🔄 Refrescar solicitudes manualmente
  Future<void> refreshSolicitudes() async {
    if (_isLoadingSolicitudes) return;

    try {
      await _loadInitialRequests();
    } catch (e) {
      print('❌ Error refrescando solicitudes: $e');
    }
  }

  /// 💰 Hacer oferta a una solicitud
  Future<bool> makeOffer({
    required String rideId,
    required double tarifa,
    required int tiempoEstimado,
    String? mensaje,
  }) async {
    try {
      // Enviar por HTTP
      final success = await _ridesService.makeOffer(
        rideId: rideId,
        tarifa: tarifa,
        tiempoEstimado: tiempoEstimado,
        mensaje: mensaje,
      );

      // También enviar por WebSocket para respuesta inmediata
      if (_wsService.isConnected) {
        _wsService.sendRideOffer(
          rideId: rideId,
          tarifa: tarifa,
          tiempoEstimado: tiempoEstimado,
          mensaje: mensaje,
        );
      }

      return success;
    } catch (e) {
      print('❌ Error enviando oferta: $e');
      return false;
    }
  }

  /// ❌ Rechazar solicitud
  Future<bool> rejectRequest(String rideId) async {
    try {
      final success = await _ridesService.rejectRequest(rideId);

      if (success) {
        // Remover de la lista local
        _solicitudes.removeWhere((s) => s.rideId == rideId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      print('❌ Error rechazando solicitud: $e');
      return false;
    }
  }

  /// 🧹 Limpiar recursos
  @override
  void dispose() {
    _locationTimer?.cancel();
    _requestsTimer?.cancel();
    _pingTimer?.cancel();
    _wsService.disconnect();
    super.dispose();
  }
}

// Mantener clases existentes para compatibilidad
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
