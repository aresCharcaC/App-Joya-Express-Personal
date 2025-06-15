// lib/presentation/modules/auth/Driver/viewmodels/driver_home_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:joya_express/data/models/user/ride_request_model.dart';
import '../../../../../data/services/rides_service.dart';
import '../../../../../data/services/websocket_service.dart';
import 'driver_settings_viewmodel.dart';
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

  // Configuración del conductor
  DriverSettingsViewModel? _settingsViewModel;

  // Getters
  bool get disponible => _disponible;
  bool get isLoadingSolicitudes => _isLoadingSolicitudes;
  String? get error => _error;
  List<dynamic> get solicitudes => _solicitudes;
  Driver? get currentDriver => _currentDriver;
  Position? get currentPosition => _currentPosition;

  /// 🚀 Inicializar con servicios reales
  Future<void> init({String? conductorId, String? token}) async {
    print('🚀 Inicializando DriverHomeViewModel...');

    try {
      // Datos del conductor actual
      _currentDriver = Driver(
        id: conductorId ?? '1',
        nombreCompleto: 'Luis Pérez',
        telefono: '987654321',
      );

      // Inicializar configuración del conductor
      _settingsViewModel = DriverSettingsViewModel();
      await _settingsViewModel!.init();

      // Obtener ubicación inicial
      await _initializeLocation();

      // Conectar WebSocket si hay datos de autenticación
      if (conductorId != null && token != null) {
        await _connectWebSocket(conductorId, token);
      }

      // Cargar solicitudes iniciales
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

      // Agregar a la lista si no existe
      final exists = _solicitudes.any((s) => s['id'] == request.id);
      if (!exists) {
        _solicitudes.insert(0, request.toJson()); // Agregar al inicio
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
    _solicitudes.removeWhere((s) => s['id'] == data['rideId']);
    notifyListeners();
  }

  /// 📋 Cargar solicitudes iniciales
  Future<void> _loadInitialRequests() async {
    _isLoadingSolicitudes = true;
    notifyListeners();

    try {
      // Asegurar que tenemos ubicación actualizada en el backend
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

      // Cargar solicitudes reales del backend
      try {
        final realRequests = await _ridesService.getNearbyRequests();

        // Filtrar por distancia si tenemos ubicación
        if (_currentPosition != null) {
          // Usar la configuración de distancia del conductor
          final maxDistanceMeters =
              _settingsViewModel?.searchRadiusMeters ?? 1000.0;

          final solicitudesFiltradas = _filterByDistance(
            realRequests.map((r) => r.toJson()).toList(),
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            maxDistanceMeters,
          );

          // Aplicar filtros y ordenamiento de configuración
          List<dynamic> solicitudesProcesadas = solicitudesFiltradas;

          if (_settingsViewModel != null) {
            // Aplicar filtros
            solicitudesProcesadas = _settingsViewModel!.applyFilters(
              solicitudesProcesadas,
              getPrice:
                  (solicitud) =>
                      solicitud['precioSugerido']?.toDouble() ??
                      solicitud['precio_sugerido']?.toDouble() ??
                      0.0,
            );

            // Aplicar ordenamiento
            solicitudesProcesadas = _settingsViewModel!.applySorting(
              solicitudesProcesadas,
              getDistance: (solicitud) {
                double origenLat =
                    solicitud['origenLat'] ?? solicitud['origen_lat'] ?? 0.0;
                double origenLng =
                    solicitud['origenLng'] ?? solicitud['origen_lng'] ?? 0.0;
                return _calculateHaversineDistance(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      origenLat,
                      origenLng,
                    ) /
                    1000; // Convertir a km
              },
              getPrice:
                  (solicitud) =>
                      solicitud['precioSugerido']?.toDouble() ??
                      solicitud['precio_sugerido']?.toDouble() ??
                      0.0,
              getTime: (solicitud) {
                try {
                  String? fechaStr =
                      solicitud['fechaCreacion'] ??
                      solicitud['fecha_creacion'] ??
                      solicitud['fecha_solicitud'];
                  if (fechaStr != null) {
                    return DateTime.parse(fechaStr);
                  }
                } catch (e) {
                  print('Error parseando fecha: $e');
                }
                return DateTime.now();
              },
            );
          }

          _solicitudes = solicitudesProcesadas;
          print(
            '🔍 Filtrado: ${solicitudesProcesadas.length} de ${realRequests.length} solicitudes mostradas (radio: ${(maxDistanceMeters / 1000).toStringAsFixed(1)}km)',
          );
        } else {
          // Si no hay ubicación, mostrar todas
          _solicitudes = realRequests.map((r) => r.toJson()).toList();
          print(
            '⚠️ Sin ubicación del conductor, mostrando todas las solicitudes',
          );
        }

        print('✅ ${realRequests.length} solicitudes reales cargadas');
      } catch (e) {
        print('⚠️ No se pudieron cargar solicitudes reales: $e');
        _solicitudes = [];
      }

      _error = null;
    } catch (e) {
      print('❌ Error cargando solicitudes: $e');
      _error = 'Error cargando solicitudes: $e';
      _solicitudes = [];
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
        double origenLat =
            solicitud['origenLat'] ?? solicitud['origen_lat'] ?? 0.0;
        double origenLng =
            solicitud['origenLng'] ?? solicitud['origen_lng'] ?? 0.0;

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
            '✅ Solicitud ${solicitud['id']} agregada - ${distanceMeters.round()}m',
          );
        } else {
          print(
            '❌ Solicitud ${solicitud['id']} filtrada - ${distanceMeters.round()}m (muy lejos)',
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

  /// 🔄 Cambiar disponibilidad del conductor
  Future<void> setDisponible(bool value) async {
    final oldValue = _disponible;
    _disponible = value;
    notifyListeners();

    try {
      if (_disponible) {
        await _startLocationUpdates();
        _startRequestsPolling();
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
        _solicitudes.removeWhere((s) => s['id'] == rideId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      print('❌ Error rechazando solicitud: $e');
      return false;
    }
  }

  /// ⚙️ Obtener configuración actual del conductor
  DriverSettingsViewModel? get settingsViewModel => _settingsViewModel;

  /// 🔄 Recargar configuración del conductor
  Future<void> reloadSettings() async {
    if (_settingsViewModel != null) {
      await _settingsViewModel!.init();
      // Recargar solicitudes con nueva configuración
      await refreshSolicitudes();
      print('✅ Configuración del conductor recargada');
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

// Clase para compatibilidad
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
