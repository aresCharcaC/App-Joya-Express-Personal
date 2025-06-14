import '../entities/oferta_viaje_entity.dart';
import '../repositories/oferta_viaje_repository.dart';

class ObtenerOfertasUseCase {
  final OfertaViajeRepository repository;

  ObtenerOfertasUseCase({
    required this.repository,
  });

  Future<PaginatedResponse<OfertaViaje>> execute(
    String rideId, {
    int page = 1,
    int pageSize = 10,
    OfertaFilters? filters,
  }) async {
    try {
      // Validaciones de negocio
      if (rideId.isEmpty) {
        throw Exception('El ID del viaje no puede estar vacío');
      }

      if (page < 1) {
        throw Exception('La página debe ser mayor o igual a 1');
      }

      if (pageSize < 1 || pageSize > 50) {
        throw Exception('El tamaño de página debe estar entre 1 y 50');
      }

      // Llamada al repositorio
      final ofertas = await repository.obtenerOfertas(
        rideId,
        page: page,
        pageSize: pageSize,
        filters: filters,
      );
      return ofertas;
    } catch (e) {
      throw Exception('Error en el caso de uso: $e');
    }
  }
} 