import '../../domain/entities/ride_request_entity.dart';
// RideRequestModel extiende RideRequestEntity para heredar todas sus propiedades
// Pero añade funcionalidades específicas de la capa de datos (JSON conversion)
class RideRequestModel extends RideRequest {
  // Constructor que simplemente pasa todos los parámetros al constructor padre
  RideRequestModel({
    String? id,// Pasa el id al constructor de RideRequestEntity
    required double origenLat,
    required double origenLng,
    required double destinoLat,
    required double destinoLng,
    String? origenDireccion,
    String? destinoDireccion,
    double? precioSugerido,
    String? notas,
    String metodoPagoPreferido = 'efectivo',
    String? estado,
    DateTime? fechaCreacion,
  }) : super(
          id: id,
          origenLat: origenLat,
          origenLng: origenLng,
          destinoLat: destinoLat,
          destinoLng: destinoLng,
          origenDireccion: origenDireccion,
          destinoDireccion: destinoDireccion,
          precioSugerido: precioSugerido,
          notas: notas,
          metodoPagoPreferido: metodoPagoPreferido,
          estado: estado,
          fechaCreacion: fechaCreacion,
        );
 // Factory constructor que convierte un Map<String, dynamic> a RideRequestModel
 // Se usa cuando recibimos datos del servidor en formato JSON
  factory RideRequestModel.fromJson(Map<String, dynamic> json) {
    return RideRequestModel(
      // Extrae el ID del viaje desde la respuesta del servidor
      id: json['viaje_id'],
            // Extrae coordenadas del origen desde el objeto anidado 'origen'
      origenLat: json['origen']['lat'].toDouble(),
      origenLng: json['origen']['lng'].toDouble(),
      destinoLat: json['destino']['lat'].toDouble(),
      destinoLng: json['destino']['lng'].toDouble(),
      origenDireccion: json['origen']['direccion'],
      destinoDireccion: json['destino']['direccion'],
      precioSugerido: json['precio_sugerido']?.toDouble(),
      estado: json['estado'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      metodoPagoPreferido: json['metodo_pago_preferido'] ?? 'efectivo',
    );
  }
  // Método que convierte el objeto RideRequestModel a Map<String, dynamic>
  // Se usa cuando enviamos datos al servidor
  Map<String, dynamic> toJson() {
    return {
      // Campos obligatorios que siempre se envían
      'origen_lat': origenLat,
      'origen_lng': origenLng,
      'destino_lat': destinoLat,
      'destino_lng': destinoLng,
      'metodo_pago_preferido': metodoPagoPreferido,
      
      // Campos opcionales: solo se incluyen si no son null
      if (origenDireccion != null) 'origen_direccion': origenDireccion,
      if (destinoDireccion != null) 'destino_direccion': destinoDireccion,
      if (precioSugerido != null) 'precio_sugerido': precioSugerido,
      if (notas != null) 'notas': notas,
    };
  }
} 