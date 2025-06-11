// lib/presentation/modules/auth/Driver/viewmodels/driver_home_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../data/services/rides_service.dart';
import '../../../../../data/services/websocket_service.dart';
import '../../../../../data/models/ride_request_model.dart';

class DriverHomeViewModel extends ChangeNotifier {
  final RidesService _ridesService = RidesService();
  final WebSocketService _wsService = WebSocketService();

  // Estado del conductor
  bool _disponible = false;
  bool _isLoadingSolicitudes = false;
  String? _error;
  bool _hasAutoOpenedOnce = false; // ✅ Flag para auto-abrir solo una vez

  // Callback para auto-abrir modal
  Function(dynamic)? _onAutoOpenRequest;

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
  List<dynamic> get solicitudes =>
      _getSolicitudesFiltradas(); // ✅ Filtrar por distancia
  List<dynamic> get todasLasSolicitudes => _solicitudes; // ✅ NUEVO: Sin filtrar
  Driver? get currentDriver => _currentDriver;
  Position? get currentPosition => _currentPosition;

  /// 🎯 Filtrar solicitudes por radio de 7 cuadras (≈0.8km)
  List<dynamic> _getSolicitudesFiltradas() {
    if (!_disponible) {
      // En modo OCUPADO: mostrar todas (sin filtro de distancia)
      return _solicitudes;
    }

    // En modo DISPONIBLE: solo mostrar cercanas (7 cuadras máximo)
    return _solicitudes.where((solicitud) {
      final distancia = solicitud.distanciaKm ?? 999.0;
      return distancia <= 0.8; // 7 cuadras ≈ 0.8km
    }).toList();
  }

  /// ✅ Registrar callback para auto-abrir modal
  void setAutoOpenCallback(Function(dynamic)? callback) {
    _onAutoOpenRequest = callback;
  }

  /// 🚀 Inicializar con servicios reales + GPS inmediato
  Future<void> init({String? conductorId, String? token}) async {
    print('🚀 Inicializando DriverHomeViewModel...');

    try {
      // Simular datos del conductor actual
      _currentDriver = Driver(
        id: conductorId ?? '1',
        nombreCompleto: 'Luis Pérez',
        telefono: '987654321',
      );

      // ✅ OBTENER UBICACIÓN INMEDIATAMENTE (no esperar a disponible)
      await _initializeLocationAndBackend();

      // Conectar WebSocket si hay datos de autenticación
      if (conductorId != null && token != null) {
        await _connectWebSocket(conductorId, token);
      }

      // Cargar solicitudes iniciales (solo mocks por ahora)
      await _loadInitialRequests();

      print('✅ DriverHomeViewModel inicializado');
    } catch (e) {
      print('❌ Error inicializando DriverHomeViewModel: $e');
      _error = 'Error al inicializar: $e';
    }

    notifyListeners();
  }

  /// 📍 Inicializar ubicación Y actualizar backend inmediatamente
  Future<void> _initializeLocationAndBackend() async {
    try {
      print('📍 Obteniendo ubicación GPS...');
      _currentPosition = await _ridesService.getCurrentLocation();

      if (_currentPosition != null) {
        print(
          '📍 Ubicación obtenida: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
        );

        // ✅ ACTUALIZAR BACKEND INMEDIATAMENTE
        try {
          await _ridesService.updateDriverLocation(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
          print('✅ Coordenadas enviadas al backend desde login');
        } catch (e) {
          print('⚠️ Error enviando coordenadas al login: $e');
          // No es crítico, seguir con la inicialización
        }
      } else {
        print('⚠️ No se pudo obtener ubicación GPS');
      }
    } catch (e) {
      print('❌ Error inicializando ubicación: $e');
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

      // 3. Agregar mocks si hay pocas solicitudes reales
      if (allRequests.length < 3) {
        final mockSolicitudes = _generateMockRequests();
        allRequests.addAll(mockSolicitudes);
        print('✅ ${mockSolicitudes.length} solicitudes mock agregadas');
      }

      _solicitudes = allRequests;
      _error = null;
    } catch (e) {
      print('❌ Error cargando solicitudes: $e');
      _error = 'Error cargando solicitudes: $e';

      // Fallback a solo mocks
      _solicitudes = _generateMockRequests();
    }

    _isLoadingSolicitudes = false;
    notifyListeners();
  }

  /// 🎭 Generar 10 solicitudes mock con coordenadas reales de Arequipa
  List<dynamic> _generateMockRequests() {
    // Ubicación base del conductor (para calcular distancias)
    final conductorLat = _currentPosition?.latitude ?? -16.4090;
    final conductorLng = _currentPosition?.longitude ?? -71.5375;

    return [
      // ✅ CERCANAS (dentro de 7 cuadras ≈ 0.8km)
      MockSolicitud(
        rideId: 'mock_1',
        usuarioId: 'user_1',
        nombre: 'María Elena',
        foto: 'https://randomuser.me/api/portraits/women/1.jpg',
        precio: 7.5,
        direccion: 'Av. Bolognesi 245, Cercado', // 0.3km del centro
        metodos: ['Yape', 'Efectivo'],
        rating: 4.77,
        votos: 35,
        origenLat: -16.4067,
        origenLng: -71.5355,
        destinoDireccion: 'Plaza de Armas de Arequipa',
        destinoLat: -16.3989,
        destinoLng: -71.5370,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 2)),
        distanciaKm: 0.3,
        tiempoEstimadoMinutos: 4,
      ),

      MockSolicitud(
        rideId: 'mock_2',
        usuarioId: 'user_2',
        nombre: 'Carlos Miguel',
        foto: 'https://randomuser.me/api/portraits/men/2.jpg',
        precio: 8.0,
        direccion: 'Calle Mercaderes 123, Centro', // 0.5km del centro
        metodos: ['Plin', 'Yape'],
        rating: 4.85,
        votos: 42,
        origenLat: -16.4015,
        origenLng: -71.5385,
        destinoDireccion: 'Terminal Terrestre Arequipa',
        destinoLat: -16.4150,
        destinoLng: -71.5320,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 3)),
        distanciaKm: 0.5,
        tiempoEstimadoMinutos: 6,
      ),

      MockSolicitud(
        rideId: 'mock_3',
        usuarioId: 'user_3',
        nombre: 'Ana Lucía',
        foto: 'https://randomuser.me/api/portraits/women/3.jpg',
        precio: 6.5,
        direccion: 'Av. La Marina 567, Sachaca', // 0.7km
        metodos: ['Efectivo'],
        rating: 4.60,
        votos: 28,
        origenLat: -16.4045,
        origenLng: -71.5420,
        destinoDireccion: 'Mirador de Yanahuara',
        destinoLat: -16.3925,
        destinoLng: -71.5447,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 5)),
        distanciaKm: 0.7,
        tiempoEstimadoMinutos: 8,
      ),

      MockSolicitud(
        rideId: 'mock_4',
        usuarioId: 'user_4',
        nombre: 'Roberto Silva',
        foto: 'https://randomuser.me/api/portraits/men/4.jpg',
        precio: 9.0,
        direccion: 'Calle San Juan de Dios 89, Cercado', // 0.4km
        metodos: ['Yape', 'Plin', 'Efectivo'],
        rating: 4.92,
        votos: 67,
        origenLat: -16.4025,
        origenLng: -71.5365,
        destinoDireccion: 'Hospital Nacional Carlos A. Seguín',
        destinoLat: -16.3850,
        destinoLng: -71.5180,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 1)),
        distanciaKm: 0.4,
        tiempoEstimadoMinutos: 5,
      ),

      MockSolicitud(
        rideId: 'mock_5',
        usuarioId: 'user_5',
        nombre: 'Sofía Mendoza',
        foto: 'https://randomuser.me/api/portraits/women/5.jpg',
        precio: 7.0,
        direccion: 'Av. Goyeneche 234, San Lázaro', // 0.6km
        metodos: ['Plin'],
        rating: 4.45,
        votos: 23,
        origenLat: -16.4110,
        origenLng: -71.5390,
        destinoDireccion: 'Monasterio de Santa Catalina',
        destinoLat: -16.3966,
        destinoLng: -71.5368,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 7)),
        distanciaKm: 0.6,
        tiempoEstimadoMinutos: 7,
      ),

      // ❌ LEJANAS (más de 7 cuadras - NO deberían aparecer en disponible)
      MockSolicitud(
        rideId: 'mock_6',
        usuarioId: 'user_6',
        nombre: 'Diego Paredes',
        foto: 'https://randomuser.me/api/portraits/men/6.jpg',
        precio: 12.0,
        direccion: 'Av. Ejercito 1205, Miraflores', // 2.1km - LEJOS
        metodos: ['Yape', 'Efectivo'],
        rating: 4.33,
        votos: 19,
        origenLat: -16.4320,
        origenLng: -71.5098, // Mall Aventura zona
        destinoDireccion: 'Aeropuerto Internacional Arequipa',
        destinoLat: -16.3411,
        destinoLng: -71.5831,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 10)),
        distanciaKm: 2.1,
        tiempoEstimadoMinutos: 15,
      ),

      MockSolicitud(
        rideId: 'mock_7',
        usuarioId: 'user_7',
        nombre: 'Patricia Flores',
        foto: 'https://randomuser.me/api/portraits/women/7.jpg',
        precio: 15.0,
        direccion: 'Av. Lambramani 890, Hunter', // 3.2km - MUY LEJOS
        metodos: ['Plin', 'Efectivo'],
        rating: 4.78,
        votos: 85,
        origenLat: -16.4580,
        origenLng: -71.5220,
        destinoDireccion: 'Universidad Nacional San Agustín',
        destinoLat: -16.4030,
        destinoLng: -71.5290,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 12)),
        distanciaKm: 3.2,
        tiempoEstimadoMinutos: 20,
      ),

      MockSolicitud(
        rideId: 'mock_8',
        usuarioId: 'user_8',
        nombre: 'Fernando Torres',
        foto: 'https://randomuser.me/api/portraits/men/8.jpg',
        precio: 10.5,
        direccion: 'Calle Rivero 445, Selva Alegre', // 1.8km - LEJOS
        metodos: ['Yape'],
        rating: 4.12,
        votos: 31,
        origenLat: -16.3780,
        origenLng: -71.5480,
        destinoDireccion: 'Real Plaza Centro Cívico',
        destinoLat: -16.4095,
        destinoLng: -71.5385,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 8)),
        distanciaKm: 1.8,
        tiempoEstimadoMinutos: 12,
      ),

      MockSolicitud(
        rideId: 'mock_9',
        usuarioId: 'user_9',
        nombre: 'Carmen Huamán',
        foto: 'https://randomuser.me/api/portraits/women/9.jpg',
        precio: 13.5,
        direccion: 'Av. Venezuela 1120, Paucarpata', // 4.1km - MUY LEJOS
        metodos: ['Efectivo'],
        rating: 4.65,
        votos: 52,
        origenLat: -16.4450,
        origenLng: -71.4980,
        destinoDireccion: 'Plaza San Francisco',
        destinoLat: -16.3995,
        destinoLng: -71.5375,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 15)),
        distanciaKm: 4.1,
        tiempoEstimadoMinutos: 25,
      ),

      MockSolicitud(
        rideId: 'mock_10',
        usuarioId: 'user_10',
        nombre: 'Luis Alberto',
        foto: 'https://randomuser.me/api/portraits/men/10.jpg',
        precio: 18.0,
        direccion: 'Av. Aviación 2340, Cerro Colorado', // 5.8km - SÚPER LEJOS
        metodos: ['Yape', 'Plin'],
        rating: 4.88,
        votos: 94,
        origenLat: -16.3320,
        origenLng: -71.5890,
        destinoDireccion: 'Centro Comercial Arequipa Center',
        destinoLat: -16.4102,
        destinoLng: -71.5238,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 20)),
        distanciaKm: 5.8,
        tiempoEstimadoMinutos: 35,
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
        // Activar disponible
        await _startLocationUpdates();
        _startRequestsPolling();

        // ✅ AUTO-ABRIR MÁS CERCANA (solo una vez)
        if (!_hasAutoOpenedOnce) {
          await _autoOpenClosestRequest();
          _hasAutoOpenedOnce = true;
        }

        print('✅ Conductor disponible - Servicios iniciados');
      } else {
        // Desactivar disponible
        _stopLocationUpdates();
        _stopRequestsPolling();

        // Reset flag para próxima activación
        _hasAutoOpenedOnce = false;

        print('⏹️ Conductor no disponible - Servicios detenidos');
      }
    } catch (e) {
      print('❌ Error cambiando disponibilidad: $e');
      // Revertir cambio en caso de error
      _disponible = oldValue;
      notifyListeners();
    }
  }

  /// 🚨 Auto-abrir solicitud más cercana (solo al activar disponible)
  Future<void> _autoOpenClosestRequest() async {
    try {
      final solicitudesCercanas = _getSolicitudesFiltradas();

      if (solicitudesCercanas.isNotEmpty) {
        // Encontrar la más cercana
        dynamic masCercana = solicitudesCercanas.first;
        double menorDistancia = masCercana.distanciaKm ?? 999.0;

        for (final solicitud in solicitudesCercanas) {
          final distancia = solicitud.distanciaKm ?? 999.0;
          if (distancia < menorDistancia) {
            menorDistancia = distancia;
            masCercana = solicitud;
          }
        }

        print(
          '🚨 Auto-abriendo solicitud más cercana: ${masCercana.nombre} (${menorDistancia}km)',
        );

        // Llamar callback para abrir modal automáticamente
        if (_onAutoOpenRequest != null) {
          // Pequeño delay para que la UI se actualice primero
          await Future.delayed(const Duration(milliseconds: 500));
          _onAutoOpenRequest!(masCercana);
        }
      } else {
        print('ℹ️ No hay solicitudes cercanas para auto-abrir');
      }
    } catch (e) {
      print('❌ Error auto-abriendo solicitud: $e');
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
