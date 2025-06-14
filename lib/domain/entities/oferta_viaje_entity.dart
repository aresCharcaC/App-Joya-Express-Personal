import 'driver_entity.dart';

class Conductor {
  final String id;
  final String nombre;
  final String telefono;
  final double calificacion;

  Conductor({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.calificacion,
  });
}

class OfertaViaje {
  final String ofertaId;
  final DriverEntity conductor;
  final double tarifaPropuesta;
  final String mensaje;
  final String tiempoEstimado;
  final String distanciaConductor;
  final String estado;
  final DateTime fechaOferta;

  OfertaViaje({
    required this.ofertaId,
    required this.conductor,
    required this.tarifaPropuesta,
    required this.mensaje,
    required this.tiempoEstimado,
    required this.distanciaConductor,
    required this.estado,
    required this.fechaOferta,
  });
}

class OfertasViajeResponse {
  final String rideId;
  final List<OfertaViaje> ofertas;
  final int totalOfertas;

  OfertasViajeResponse({
    required this.rideId,
    required this.ofertas,
    required this.totalOfertas,
  });
}

// Clase base para la respuesta paginada
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

// Clase para los filtros de ofertas
class OfertaFilters {
  final double? precioMin;
  final double? precioMax;
  final double? distanciaMax;
  final String? ordenarPor; // 'precio', 'distancia', 'tiempo'
  final bool? ordenAscendente;

  OfertaFilters({
    this.precioMin,
    this.precioMax,
    this.distanciaMax,
    this.ordenarPor,
    this.ordenAscendente,
  });

  Map<String, dynamic> toJson() {
    return {
      if (precioMin != null) 'precio_min': precioMin,
      if (precioMax != null) 'precio_max': precioMax,
      if (distanciaMax != null) 'distancia_max': distanciaMax,
      if (ordenarPor != null) 'ordenar_por': ordenarPor,
      if (ordenAscendente != null) 'orden_ascendente': ordenAscendente,
    };
  }
} 