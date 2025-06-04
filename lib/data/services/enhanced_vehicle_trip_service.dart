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

      // INTENTO 1: trip_routing con filtros ULTRA estrictos
      try {
        print('🔄 Intento #1: trip_routing con filtros estrictos...');
        return await _calculateWithTripRouting(pickup, destination);
      } catch (e) {
        print('❌ trip_routing falló: $e');

        // INTENTO 2: Overpass API directo como respaldo
        print('🔄 Intento #2: Overpass API como respaldo...');
        return await _calculateWithOverpassBackup(pickup, destination);
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
    // Ajustar puntos a carreteras vehiculares
    final snappedPickup = await _vehicleTripService.snapToVehicleRoad(
      pickup.coordinates,
    );
    final snappedDestination = await _vehicleTripService.snapToVehicleRoad(
      destination.coordinates,
    );

    // Calcular ruta usando trip_routing
    final waypoints = [snappedPickup, snappedDestination];
    final trip = await _vehicleTripService.findTotalTrip(
      waypoints,
      preferWalkingPaths: false,
      replaceWaypointsWithBuildingEntrances: false,
      forceIncludeWaypoints: false,
      duplicationPenalty: 0.0,
    );

    if (trip.route.isEmpty || trip.route.length < 2) {
      throw Exception(RouteConstants.noVehicleRouteError);
    }

    // Crear TripEntity exitoso
    return await _createTripEntity(
      trip,
      pickup,
      destination,
      snappedPickup,
      snappedDestination,
    );
  }

  /// Método de respaldo usando Overpass API directo
  Future<TripEntity> _calculateWithOverpassBackup(
    LocationEntity pickup,
    LocationEntity destination,
  ) async {
    try {
      print('🛡️ Intentando ruta con Overpass API directo...');

      // Verificar que al menos los puntos estén cerca de calles vehiculares
      final pickupOnRoad = await _isPointNearVehicleRoad(pickup.coordinates);
      final destOnRoad = await _isPointNearVehicleRoad(destination.coordinates);

      if (!pickupOnRoad || !destOnRoad) {
        throw Exception(RouteConstants.noRoadNearbyError);
      }

      // Si llegamos aquí es porque hay calles vehiculares pero trip_routing no pudo crear ruta
      // En este caso, creamos una ruta simple directa como último recurso
      final directRoute = _createDirectRoute(
        pickup.coordinates,
        destination.coordinates,
      );

      if (directRoute.isEmpty) {
        throw Exception(RouteConstants.overpassBackupFailedError);
      }

      return _createSimpleTripEntity(pickup, destination, directRoute);
    } catch (e) {
      print('❌ Overpass backup también falló: $e');
      // Lanzar error específico para UI
      throw Exception(RouteConstants.noVehicleRouteError);
    }
  }

  /// Verifica si un punto está cerca de calles vehiculares usando Overpass directo
  Future<bool> _isPointNearVehicleRoad(LatLng point) async {
    try {
      final query = '''
        [out:json];
        (
          way["highway"~"^(motorway|trunk|primary|secondary|tertiary|residential)\$"]
  ["motor_vehicle"!~"no|private"]
  ["access"!~"no"]
  ["highway"!~"pedestrian|footway|path|track"]
  ["leisure"!~"park|garden"]
  ["landuse"!~"grass|recreation_ground"]
  ["area"!="yes"]
  ["surface"!~"grass|unpaved"]
  (around:200, ${point.latitude}, ${point.longitude});
        );
        out count;
        ''';

      final url = Uri.parse('https://overpass-api.de/api/interpreter');
      final response = await http.post(url, body: {'data': query});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List?;
        return elements != null && elements.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('Error verificando punto con Overpass: $e');
      return false;
    }
  }

  /// Crea una ruta directa simple como último recurso
  List<LatLng> _createDirectRoute(LatLng start, LatLng end) {
    // Crear ruta directa simple con puntos intermedios
    final List<LatLng> route = [];
    route.add(start);

    // Agregar puntos intermedios para hacer la línea menos abrupta
    final latDiff = end.latitude - start.latitude;
    final lngDiff = end.longitude - start.longitude;

    for (int i = 1; i < 5; i++) {
      final ratio = i / 5.0;
      route.add(
        LatLng(
          start.latitude + (latDiff * ratio),
          start.longitude + (lngDiff * ratio),
        ),
      );
    }

    route.add(end);
    return route;
  }

  /// Crea TripEntity simple para ruta de respaldo
  Future<TripEntity> _createSimpleTripEntity(
    LocationEntity pickup,
    LocationEntity destination,
    List<LatLng> routePoints,
  ) async {
    final distance = _calculateDistance(
      pickup.coordinates,
      destination.coordinates,
    );
    final duration = RouteConstants.calculateEstimatedTime(distance);

    return TripEntity(
      routePoints: routePoints,
      distanceKm: distance,
      durationMinutes: duration,
      pickup: pickup.copyWith(isSnappedToRoad: true),
      destination: destination.copyWith(isSnappedToRoad: true),
      calculatedAt: DateTime.now(),
      originalTrip: null, // No hay Trip original para rutas de respaldo
    );
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
