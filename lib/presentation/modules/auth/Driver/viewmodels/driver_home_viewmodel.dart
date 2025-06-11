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

  /// 🎭 Generar solicitudes mock para desarrollo
  List<dynamic> _generateMockRequests() {
    return [
      MockSolicitud(
        rideId: 'mock_1',
        usuarioId: 'user_1',
        nombre: 'Mafer',
        foto: 'https://randomuser.me/api/portraits/women/1.jpg',
        precio: 7.5,
        direccion: 'Av. La Fontana 750, La Molina',
        metodos: ['Yape', 'Efectivo'],
        rating: 4.77,
        votos: 35,
        origenLat: -16.4090,
        origenLng: -71.5375,
        destinoDireccion: 'Real Plaza Centro Cívico',
        destinoLat: -16.4095,
        destinoLng: -71.5385,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 2)),
        distanciaKm: 1.2,
        tiempoEstimadoMinutos: 8,
      ),
      MockSolicitud(
        rideId: 'mock_2',
        usuarioId: 'user_2',
        nombre: 'Anthony',
        foto: 'https://randomuser.me/api/portraits/men/2.jpg',
        precio: 8.0,
        direccion: 'Mall Aventura Plaza AQP',
        metodos: ['Plin', 'Yape', 'Efectivo'],
        rating: 4.85,
        votos: 42,
        origenLat: -16.4320,
        origenLng: -71.5098,
        destinoDireccion: 'Universidad Nacional San Agustín',
        destinoLat: -16.4030,
        destinoLng: -71.5290,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 5)),
        distanciaKm: 2.1,
        tiempoEstimadoMinutos: 12,
      ),
      MockSolicitud(
        rideId: 'mock_3',
        usuarioId: 'user_3',
        nombre: 'Luis',
        foto: 'https://randomuser.me/api/portraits/men/3.jpg',
        precio: 6.5,
        direccion: 'Plaza de Armas de Arequipa',
        metodos: ['Yape', 'Plin'],
        rating: 4.60,
        votos: 28,
        origenLat: -16.3989,
        origenLng: -71.5370,
        destinoDireccion: 'Terminal Terrestre',
        destinoLat: -16.4150,
        destinoLng: -71.5320,
        estado: 'pendiente',
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 8)),
        distanciaKm: 3.5,
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
