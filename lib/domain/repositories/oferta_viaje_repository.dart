import '../entities/oferta_viaje_entity.dart';

abstract class OfertaViajeRepository {
  // Método para obtener ofertas con paginación y filtros
  Future<PaginatedResponse<OfertaViaje>> obtenerOfertas(
    String rideId, {
    int page = 1,
    int pageSize = 10,
    OfertaFilters? filters,
  });

  // Método para guardar ofertas en caché local
  Future<void> guardarOfertasEnCache(String rideId, List<OfertaViaje> ofertas);

  // Método para obtener ofertas desde caché local
  Future<List<OfertaViaje>?> obtenerOfertasDeCache(String rideId);

  // Método para limpiar caché de ofertas
  Future<void> limpiarCacheOfertas(String rideId);
} 