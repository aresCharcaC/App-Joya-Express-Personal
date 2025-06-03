// lib/data/services/enhanced_vehicle_trip_service.dart
import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:trip_routing/trip_routing.dart' as tr;
import '../../core/constants/route_constants.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../data/services/geocoding_service.dart';
import './vehicle_trip_service.dart'; // IMPORTAR TU VehicleTripService EXISTENTE

/// Servicio mejorado que usa VehicleTripService + trip_routing
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

  /// Calcula una ruta completa entre dos puntos
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

      // 1. Ajustar puntos a carreteras vehiculares
      print('📍 Ajustando puntos a carreteras vehiculares...');
      final snappedPickup = await _vehicleTripService.snapToVehicleRoad(
        pickup.coordinates,
      );
      final snappedDestination = await _vehicleTripService.snapToVehicleRoad(
        destination.coordinates,
      );

      // 2. Calcular ruta usando trip_routing
      print('🗺️ Calculando ruta óptima...');
      final waypoints = [snappedPickup, snappedDestination];

      final trip = await _vehicleTripService.findTotalTrip(
        waypoints,
        preferWalkingPaths: false,
        replaceWaypointsWithBuildingEntrances: false,
        forceIncludeWaypoints: false,
        duplicationPenalty: 0.0,
      );

      if (trip.route.isEmpty || trip.route.length < 2) {
        throw Exception(
          'No se encontró una ruta vehicular viable entre estos puntos. Intenta seleccionar ubicaciones más cercanas a calles principales.',
        );
      }

      // 3. Actualizar direcciones si es necesario
      final updatedPickup = await _updateLocationWithAddress(
        pickup,
        snappedPickup,
      );
      final updatedDestination = await _updateLocationWithAddress(
        destination,
        snappedDestination,
      );

      // 4. Crear TripEntity con los datos calculados
      final distanceKm = trip.distance / 1000; // Convertir metros a kilómetros
      final durationMinutes = RouteConstants.calculateEstimatedTime(distanceKm);

      final tripEntity = TripEntity(
        routePoints: trip.route,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        pickup: updatedPickup,
        destination: updatedDestination,
        calculatedAt: DateTime.now(),
        originalTrip: trip,
      );

      print('✅ Ruta calculada exitosamente:');
      print('   📏 Distancia: ${distanceKm.toStringAsFixed(2)} km');
      print('   ⏱️ Tiempo estimado: $durationMinutes minutos');
      print('   📍 Puntos de ruta: ${trip.route.length}');

      return tripEntity;
    } catch (e) {
      print('❌ Error calculando ruta: $e');

      // Manejo específico de errores
      if (e.toString().contains('timeout') ||
          e.toString().contains('TimeoutException')) {
        throw Exception(RouteConstants.timeoutError);
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        throw Exception(RouteConstants.networkError);
      } else if (e.toString().contains('No se pudo encontrar una calle')) {
        throw Exception(RouteConstants.noRoadNearbyError);
      }

      rethrow;
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

      print('📍 Ajustando punto a carretera vehicular...');
      final snappedPoint = await _vehicleTripService.snapToVehicleRoad(point);

      final distance = _calculateDistance(point, snappedPoint);
      if (distance > 0.001) {
        // Más de 1 metro
        print(
          '✅ Punto ajustado (distancia: ${(distance * 1000).toStringAsFixed(0)}m)',
        );
      } else {
        print('✅ Punto ya estaba en carretera vehicular');
      }

      return snappedPoint;
    } catch (e) {
      print('❌ Error ajustando a carretera: $e');
      return point; // Devolver punto original si falla
    }
  }

  /// Actualiza una ubicación con dirección real si es necesario
  Future<LocationEntity> _updateLocationWithAddress(
    LocationEntity original,
    LatLng snappedCoordinates,
  ) async {
    try {
      // Si las coordenadas cambiaron significativamente, actualizar dirección
      final distance = _calculateDistance(
        original.coordinates,
        snappedCoordinates,
      );

      if (distance > 0.01) {
        // Más de 10 metros
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

  /// Validaciones iniciales
  void _validateCoordinates(LatLng pickup, LatLng destination) {
    // Verificar coordenadas válidas
    if (pickup.latitude.abs() > 90 ||
        pickup.longitude.abs() > 180 ||
        destination.latitude.abs() > 90 ||
        destination.longitude.abs() > 180) {
      throw Exception(RouteConstants.invalidCoordinatesError);
    }

    // Verificar que no sean el mismo punto
    final distance = _calculateDistance(pickup, destination);
    if (distance < RouteConstants.minRouteDistanceKm) {
      throw Exception(RouteConstants.sameLocationError);
    }

    // Verificar distancia máxima
    if (distance > RouteConstants.maxRouteDistanceKm) {
      throw Exception(RouteConstants.tooFarError);
    }
  }

  /// Calcula distancia entre dos puntos en kilómetros
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Radio de la Tierra en km

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
