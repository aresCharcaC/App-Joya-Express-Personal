import 'package:latlong2/latlong.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/routing_repository.dart';
import '../services/enhanced_vehicle_trip_service.dart';

/// Implementación del repositorio de routing usando trip_routing
class RoutingRepositoryImpl implements RoutingRepository {
  final EnhancedVehicleTripService _tripService;

  RoutingRepositoryImpl({EnhancedVehicleTripService? tripService})
    : _tripService = tripService ?? EnhancedVehicleTripService();

  @override
  Future<TripEntity> calculateVehicleRoute(
    LocationEntity pickup,
    LocationEntity destination,
  ) async {
    return await _tripService.calculateRoute(pickup, destination);
  }

  @override
  Future<LatLng> snapToVehicleRoad(LatLng point) async {
    return await _tripService.snapToVehicleRoad(point);
  }

  @override
  Future<bool> isOnVehicleRoad(LatLng point) async {
    return await _tripService.isOnVehicleRoad(point);
  }
}
