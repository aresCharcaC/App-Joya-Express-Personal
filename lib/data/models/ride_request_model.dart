import '../../domain/entities/ride_request_entity.dart';

// RideRequestModel extiende RideRequestEntity para heredar todas sus propiedades
// Pero añade funcionalidades específicas de la capa de datos (JSON conversion)
class RideRequestModel extends RideRequest {
  // Constructor que simplemente pasa todos los parámetros al constructor padre
  RideRequestModel({
    String? id, // Pasa el id al constructor de RideRequestEntity
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
    // El servidor puede devolver la respuesta en diferentes formatos
    // Formato 1: { data: { viaje: {...} } } - respuesta completa del servidor
    // Formato 2: { viaje: {...} } - respuesta directa del viaje
    // Formato 3: {...} - datos directos del viaje

    Map<String, dynamic> viajeData;

    if (json.containsKey('data') && json['data'] != null) {
      // Caso: { data: { viaje: {...} } }
      if (json['data'].containsKey('viaje')) {
        viajeData = json['data']['viaje'];
      } else {
        // Caso: { data: {...} } - datos directos en data
        viajeData = json['data'];
      }
    } else if (json.containsKey('viaje')) {
      // Caso: { viaje: {...} }
      viajeData = json['viaje'];
    } else {
      // Caso: {...} - datos directos
      viajeData = json;
    }

    return RideRequestModel(
      // Extrae el ID del viaje
      id: viajeData['id'] ?? viajeData['viaje_id'],

      // Manejo seguro de coordenadas - pueden venir en diferentes formatos
      origenLat:
          _extractCoordinate(viajeData, 'origen', 'lat') ??
          viajeData['origen_lat']?.toDouble() ??
          0.0,
      origenLng:
          _extractCoordinate(viajeData, 'origen', 'lng') ??
          viajeData['origen_lng']?.toDouble() ??
          0.0,
      destinoLat:
          _extractCoordinate(viajeData, 'destino', 'lat') ??
          viajeData['destino_lat']?.toDouble() ??
          0.0,
      destinoLng:
          _extractCoordinate(viajeData, 'destino', 'lng') ??
          viajeData['destino_lng']?.toDouble() ??
          0.0,

      // Manejo seguro de direcciones
      origenDireccion:
          _extractAddress(viajeData, 'origen') ?? viajeData['origen_direccion'],
      destinoDireccion:
          _extractAddress(viajeData, 'destino') ??
          viajeData['destino_direccion'],

      precioSugerido: viajeData['precio_sugerido']?.toDouble(),
      estado: viajeData['estado'],
      fechaCreacion: _parseDate(
        viajeData['fecha_creacion'] ?? viajeData['fecha_solicitud'],
      ),
      metodoPagoPreferido: viajeData['metodo_pago_preferido'] ?? 'efectivo',
    );
  }

  // Método auxiliar para extraer coordenadas de forma segura
  static double? _extractCoordinate(
    Map<String, dynamic> data,
    String location,
    String coord,
  ) {
    try {
      if (data[location] != null && data[location][coord] != null) {
        return data[location][coord].toDouble();
      }
    } catch (e) {
      // Si hay error, devolver null para usar el valor alternativo
    }
    return null;
  }

  // Método auxiliar para extraer direcciones de forma segura
  static String? _extractAddress(Map<String, dynamic> data, String location) {
    try {
      if (data[location] != null && data[location]['direccion'] != null) {
        return data[location]['direccion'];
      }
    } catch (e) {
      // Si hay error, devolver null para usar el valor alternativo
    }
    return null;
  }

  // Método auxiliar para parsear fechas de forma segura
  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
      return dateValue as DateTime?;
    } catch (e) {
      return null;
    }
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
