import 'package:latlong2/latlong.dart';
import '../repositories/routing_repository.dart';

/// Caso de uso para verificar si un punto está en carretera vehicular
class CheckVehicleRoadUseCase {
  final RoutingRepository _repository;

  CheckVehicleRoadUseCase(this._repository);

  /// Ejecuta la verificación
  Future<bool> execute(LatLng point) async {
    try {
      return await _repository.isOnVehicleRoad(point);
    } catch (e) {
      print('CheckRoad Error: $e');
      return false; // Asumir que no está en carretera si hay error
    }
  }
}
