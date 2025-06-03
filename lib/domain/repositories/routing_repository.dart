import 'package:latlong2/latlong.dart';
import '../entities/location_entity.dart';
import '../entities/trip_entity.dart';

/// Repositorio abstracto para operaciones de routing
abstract class RoutingRepository {
  /// Calcula una ruta vehicular entre dos puntos
  Future<TripEntity> calculateVehicleRoute(
    LocationEntity pickup,
    LocationEntity destination,
  );

  /// Ajusta un punto a la carretera vehicular más cercana
  Future<LatLng> snapToVehicleRoad(LatLng point);

  /// Verifica si un punto está en una carretera vehicular
  Future<bool> isOnVehicleRoad(LatLng point);
}
