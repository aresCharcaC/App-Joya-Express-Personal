import 'package:joya_express/domain/entities/ride_request_entity.dart';
import 'package:joya_express/domain/repositories/ride_repository.dart';
import 'package:joya_express/domain/utils/ride_validator.dart';
import 'package:joya_express/domain/exceptions/ride_validation_exception.dart';
import 'dart:developer' as developer;
// Caso de uso que encapsula la lógica de negocio para crear solicitudes de viaje
class CreateRideRequestUseCase {
  final RideRepository _repository;
   // Constructor que recibe el repositorio por inyección de dependencia
  CreateRideRequestUseCase(this._repository);
  // Método que ejecuta el caso de uso
  // Recibe: RideRequest request - La solicitud de viaje a crear
  // Retorna: Future<RideRequest> - La solicitud de viaje creada
  // Lanza excepciones si hay errores
  Future<RideRequest> call(RideRequest request) async {
    try {
      developer.log('🚀 Ejecutando caso de uso: Crear solicitud de viaje', 
          name: 'CreateRideRequestUseCase');
      
      // Validar coordenadas del origen
      RideValidator.validateCoordinates(request.origenLat, request.origenLng, 'origen');

      // Validar coordenadas del destino
      RideValidator.validateCoordinates(request.destinoLat, request.destinoLng, 'destino');
      // Validar que origen y destino no sean el mismo punto
      RideValidator.validateSameLocation(
        request.origenLat, request.origenLng,
        request.destinoLat, request.destinoLng,
      );

      // Validar distancia entre origen y destino
      RideValidator.validateDistance(
        request.origenLat, request.origenLng,
        request.destinoLat, request.destinoLng,
      );

      // Validar precio sugerido si existe
      RideValidator.validatePrice(request.precioSugerido);

      // Validar método de pago
      RideValidator.validatePaymentMethod(request.metodoPagoPreferido);

      // Si todas las validaciones pasan, crear la solicitud
      final result = await _repository.createRideRequest(request);
      
      developer.log('✅ Caso de uso completado exitosamente', 
          name: 'CreateRideRequestUseCase');
      return result;
    } on RideValidationException catch (e) {
      developer.log('❌ Error de validación: ${e.message}', 
          name: 'CreateRideRequestUseCase');
      rethrow;
    } catch (e) {
      developer.log('❌ Error inesperado: $e', 
          name: 'CreateRideRequestUseCase');
      rethrow;
    }
  }
} 