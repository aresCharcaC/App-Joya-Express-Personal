import 'package:geolocator/geolocator.dart';
import '../exceptions/ride_validation_exception.dart';

class RideValidator {
  // Límites del área de servicio (La Joya)
  //static const double MIN_LAT = -16.5;
  //static const double MAX_LAT = -16.4;
  //static const double MIN_LNG = -71.6;
  //static const double MAX_LNG = -71.5;

  // Límites de precio
  static const double MIN_PRICE = 0.0;
  static const double MAX_PRICE = 500.0;

  // Métodos de pago válidos
  static const List<String> VALID_PAYMENT_METHODS = ['efectivo', 'yape', 'plin'];

  // Validar coordenadas
  static void validateCoordinates(double lat, double lng, String field) {
    if (lat < -90 || lat > 90) {
      throw RideValidationException(
        message: 'La latitud debe estar entre -90 y 90 grados',
        field: field,
      );
    }
    if (lng < -180 || lng > 180) {
      throw RideValidationException(
        message: 'La longitud debe estar entre -180 y 180 grados',
        field: field,
      );
    }
  }

  // Validar que las coordenadas estén dentro del área de servicio
  //static void validateServiceArea(double lat, double lng) {
  //if (lat < MIN_LAT || lat > MAX_LAT || lng < MIN_LNG || lng > MAX_LNG) {
  //   throw RideValidationException(
  //     message: 'Las coordenadas están fuera del área de servicio (La Joya)',
  //    );
  //  }
  //}

  // Validar distancia entre origen y destino
  static void validateDistance(double origenLat, double origenLng, double destinoLat, double destinoLng) {
    final distance = Geolocator.distanceBetween(
      origenLat, origenLng,
      destinoLat, destinoLng,
    );

    if (distance < 10) { // 10 metros mínimo
      throw RideValidationException(
        message: 'La distancia mínima entre origen y destino debe ser de 10 metros',
      );
    }

    if (distance > 50000) { // 50 kilómetros máximo
      throw RideValidationException(
        message: 'La distancia máxima entre origen y destino debe ser de 50 kilómetros',
      );
    }
  }

  // Validar precio sugerido
  static void validatePrice(double? price) {
    if (price != null) {
      if (price < MIN_PRICE) {
        throw RideValidationException(
          message: 'El precio sugerido debe ser positivo',
          field: 'precio_sugerido',
        );
      }
      if (price > MAX_PRICE) {
        throw RideValidationException(
          message: 'El precio sugerido no puede exceder S/. 500',
          field: 'precio_sugerido',
        );
      }
    }
  }

  // Validar método de pago
  static void validatePaymentMethod(String method) {
    if (!VALID_PAYMENT_METHODS.contains(method)) {
      throw RideValidationException(
        message: 'Método de pago inválido. Debe ser uno de: ${VALID_PAYMENT_METHODS.join(", ")}',
        field: 'metodo_pago_preferido',
      );
    }
  }

  // Validar que el origen y destino no sean el mismo punto
  static void validateSameLocation(double origenLat, double origenLng, double destinoLat, double destinoLng) {
    if (origenLat == destinoLat && origenLng == destinoLng) {
      throw RideValidationException(
        message: 'El origen y destino no pueden ser el mismo punto',
      );
    }
  }
} 