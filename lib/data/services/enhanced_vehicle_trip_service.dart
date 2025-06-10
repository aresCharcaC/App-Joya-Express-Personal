// lib/data/services/enhanced_vehicle_trip_service.dart
import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:trip_routing/trip_routing.dart' as tr;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/route_constants.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../data/services/geocoding_service.dart';
import './vehicle_trip_service.dart';

/// Servicio mejorado con sistema de respaldo para rutas vehiculares
class EnhancedVehicleTripService {
  static final EnhancedVehicleTripService _instance =
      EnhancedVehicleTripService._internal();
  factory EnhancedVehicleTripService() => _instance;
  EnhancedVehicleTripService._internal();

  late final VehicleTripService _vehicleTripService;
  bool _isInitialized = false;

  /// Inicializa el servicio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _vehicleTripService = VehicleTripService();
      _isInitialized = true;
      print('✅ EnhancedVehicleTripService inicializado');
    } catch (e) {
      print('❌ Error inicializando VehicleTripService: $e');
      rethrow;
    }
  }

  /// Calcula una ruta completa entre dos puntos CON SISTEMA DE RESPALDO
  Future<TripEntity> calculateRoute(
    LocationEntity pickup,
    LocationEntity destination,
  ) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      print('🚗 Iniciando cálculo de ruta vehicular...');
      print('📍 Desde: ${pickup.address ?? pickup.coordinates.toString()}');
      print(
        '📍 Hasta: ${destination.address ?? destination.coordinates.toString()}',
      );

      // Validaciones iniciales
      _validateCoordinates(pickup.coordinates, destination.coordinates);

      // ✅ SOLO UN INTENTO: trip_routing con filtros estrictos
      try {
        print('🔄 Calculando ruta con trip_routing...');
        return await _calculateWithTripRouting(pickup, destination);
      } catch (e) {
        print('❌ No se pudo crear ruta vehicular: $e');

        // ✅ NO hay respaldo directo - fallar inmediatamente
        throw Exception(RouteConstants.noVehicleRouteError);
      }
    } catch (e) {
      print('❌ Error completo calculando ruta: $e');
      rethrow;
    }
  }

  /// Método principal usando trip_routing
  Future<TripEntity> _calculateWithTripRouting(
    LocationEntity pickup,
    LocationEntity destination,
  ) async {
    try {
      // ✅ Verificar primero que los puntos estén cerca de calles vehiculares
      final pickupOnRoad = await _isPointNearVehicleRoad(pickup.coordinates);
      final destOnRoad = await _isPointNearVehicleRoad(destination.coordinates);

      if (!pickupOnRoad || !destOnRoad) {
        throw Exception(RouteConstants.selectDifferentPointsError);
      }

      // Ajustar puntos a carreteras vehiculares (más estricto)
      final snappedPickup = await _vehicleTripService.snapToVehicleRoad(
        pickup.coordinates,
      );
      final snappedDestination = await _vehicleTripService.snapToVehicleRoad(
        destination.coordinates,
      );

      print('✅ Puntos ajustados a calles vehiculares');

      // Calcular ruta usando trip_routing
      final waypoints = [snappedPickup, snappedDestination];
      final trip = await _vehicleTripService.findTotalTrip(
        waypoints,
        preferWalkingPaths: false,
        replaceWaypointsWithBuildingEntrances: false,
        forceIncludeWaypoints: false,
        duplicationPenalty: 0.0,
      );

      // ✅ VALIDACIÓN MÁS ESTRICTA
      if (trip.route.isEmpty || trip.route.length < 2) {
        throw Exception('No se generó una ruta vehicular válida');
      }

      // ✅ VALIDAR que la ruta no sea demasiado directa (posible línea recta)
      if (trip.route.length < 5) {
        final directDistance = _calculateDistance(
          snappedPickup,
          snappedDestination,
        );
        final routeDistance = trip.distance / 1000;

        // Si la ruta es casi igual a la distancia directa, es sospechosa
        if ((routeDistance / directDistance) < 1.2) {
          throw Exception(
            'La ruta generada es demasiado directa - posible línea recta',
          );
        }
      }

      print('✅ Ruta vehicular válida generada con ${trip.route.length} puntos');

      // Crear TripEntity exitoso
      return await _createTripEntity(
        trip,
        pickup,
        destination,
        snappedPickup,
        snappedDestination,
      );
    } catch (e) {
      print('❌ Error en trip_routing: $e');
      rethrow;
    }
  }

  /// Verifica si un punto está cerca de calles vehiculares usando Overpass directo
  Future<bool> _isPointNearVehicleRoad(LatLng point) async {
    try {
      final query = '''
      [out:json];
      (
        // SOLO CALLES PRINCIPALES Y SECUNDARIAS
        way["highway"~"^(primary|secondary|tertiary|residential)\$"]
           ["motor_vehicle"!="no"]
           ["access"!="private"]
           ["highway"!="pedestrian"]
           ["highway"!="footway"]
           ["highway"!="path"]
           (around:100, ${point.latitude}, ${point.longitude});
      );
      out count;
      ''';

      final url = Uri.parse('https://overpass-api.de/api/interpreter');
      final response = await http.post(url, body: {'data': query});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List?;
        final hasRoads = elements != null && elements.isNotEmpty;

        print('🔍 Punto ${hasRoads ? "CERCA" : "LEJOS"} de calles vehiculares');
        return hasRoads;
      }
      return false;
    } catch (e) {
      print('Error verificando calles cercanas: $e');
      return false;
    }
  }

  /// Crea TripEntity desde Trip de trip_routing
  Future<TripEntity> _createTripEntity(
    tr.Trip trip,
    LocationEntity pickup,
    LocationEntity destination,
    LatLng snappedPickup,
    LatLng snappedDestination,
  ) async {
    // Actualizar direcciones si es necesario
    final updatedPickup = await _updateLocationWithAddress(
      pickup,
      snappedPickup,
    );
    final updatedDestination = await _updateLocationWithAddress(
      destination,
      snappedDestination,
    );

    final distanceKm = trip.distance / 1000;
    final durationMinutes = RouteConstants.calculateEstimatedTime(distanceKm);

    return TripEntity(
      routePoints: trip.route,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      pickup: updatedPickup,
      destination: updatedDestination,
      calculatedAt: DateTime.now(),
      originalTrip: trip,
    );
  }

  /// Actualiza una ubicación con dirección real si es necesario
  Future<LocationEntity> _updateLocationWithAddress(
    LocationEntity original,
    LatLng snappedCoordinates,
  ) async {
    try {
      final distance = _calculateDistance(
        original.coordinates,
        snappedCoordinates,
      );

      if (distance > 0.01) {
        final newAddress = await GeocodingService.getStreetNameFromCoordinates(
          snappedCoordinates,
        );

        return original.copyWith(
          coordinates: snappedCoordinates,
          address: newAddress ?? original.address,
          isSnappedToRoad: true,
        );
      }

      return original.copyWith(
        coordinates: snappedCoordinates,
        isSnappedToRoad: true,
      );
    } catch (e) {
      print('Error actualizando dirección: $e');
      return original.copyWith(
        coordinates: snappedCoordinates,
        isSnappedToRoad: true,
      );
    }
  }

  /// Verifica si un punto está en una carretera vehicular
  Future<bool> isOnVehicleRoad(LatLng point) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return await _vehicleTripService.isOnVehicleRoad(point);
    } catch (e) {
      print('Error verificando si está en carretera: $e');
      return false;
    }
  }

  /// Ajusta un punto a la carretera vehicular más cercana
  Future<LatLng> snapToVehicleRoad(LatLng point) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return await _vehicleTripService.snapToVehicleRoad(point);
    } catch (e) {
      print('❌ Error ajustando a carretera: $e');
      rethrow; // Re-lanzar para manejo específico arriba
    }
  }

  /// Validaciones iniciales
  void _validateCoordinates(LatLng pickup, LatLng destination) {
    if (pickup.latitude.abs() > 90 ||
        pickup.longitude.abs() > 180 ||
        destination.latitude.abs() > 90 ||
        destination.longitude.abs() > 180) {
      throw Exception(RouteConstants.invalidCoordinatesError);
    }

    final distance = _calculateDistance(pickup, destination);
    if (distance < RouteConstants.minRouteDistanceKm) {
      throw Exception(RouteConstants.sameLocationError);
    }

    if (distance > RouteConstants.maxRouteDistanceKm) {
      throw Exception(RouteConstants.tooFarError);
    }
  }

  /// Calcula distancia entre dos puntos en kilómetros
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371;

    final lat1Rad = point1.latitude * (pi / 180);
    final lat2Rad = point2.latitude * (pi / 180);
    final deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    final a =
        pow(sin(deltaLatRad / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(deltaLngRad / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
