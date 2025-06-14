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
  //Calcula una ruta entre un punto de recogida y un destino, devolviendo una entidad de viaje (TripEntity).
  Future<TripEntity> calculateVehicleRoute(
    LocationEntity pickup,
    LocationEntity destination,
  ) async {
    return await _tripService.calculateRoute(pickup, destination);
  }

  @override
  //Ajusta una coordenada (LatLng) a la carretera más cercana.
  Future<LatLng> snapToVehicleRoad(LatLng point) async {
    return await _tripService.snapToVehicleRoad(point);
  }

  @override
  //Verifica si una coordenada específica está ubicada en una carretera para vehículos.
  Future<bool> isOnVehicleRoad(LatLng point) async {
    return await _tripService.isOnVehicleRoad(point);
  }
}
