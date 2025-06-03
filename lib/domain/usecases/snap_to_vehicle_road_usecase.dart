import 'package:latlong2/latlong.dart';
import '../repositories/routing_repository.dart';

/// Caso de uso para ajustar puntos a carreteras vehiculares
class SnapToVehicleRoadUseCase {
  final RoutingRepository _repository;

  SnapToVehicleRoadUseCase(this._repository);

  /// Ejecuta el ajuste a carretera
  Future<LatLng> execute(LatLng point) async {
    try {
      return await _repository.snapToVehicleRoad(point);
    } catch (e) {
      print('SnapToRoad Error: $e');
      rethrow;
    }
  }
}
