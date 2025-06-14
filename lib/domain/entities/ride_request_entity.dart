// Esta clase representa la entidad de negocio "Viaje" en el dominio
class RideRequest {
  // Propiedades inmutables (final) que definen un viaje
  final String? id;
  final double origenLat;
  final double origenLng;
  final double destinoLat;
  final double destinoLng;
  final String? origenDireccion;
  final String? destinoDireccion;
  final double? precioSugerido;
  final String? notas;
  final String metodoPagoPreferido;
  final String? estado;
  final DateTime? fechaCreacion;
  
  // Constructor que requiere los campos obligatorios y acepta opcionales

  RideRequest({
    this.id,
    required this.origenLat,
    required this.origenLng,
    required this.destinoLat,
    required this.destinoLng,
    this.origenDireccion,
    this.destinoDireccion,
    this.precioSugerido,
    this.notas,
    this.metodoPagoPreferido = 'efectivo',
    this.estado,
    this.fechaCreacion,
  });
} 