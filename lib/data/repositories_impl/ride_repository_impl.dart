import 'package:joya_express/core/network/api_exceptions.dart';
import 'package:joya_express/domain/entities/ride_request_entity.dart';
import 'package:joya_express/domain/repositories/ride_repository.dart';
import 'package:joya_express/data/models/ride_request_model.dart';
import 'dart:developer' as developer;
import 'package:joya_express/data/datasources/ride_remote_datasource.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDataSource _remoteDataSource;
  // Constructor que recibe una instancia de RideRemoteDataSource
  RideRepositoryImpl({required RideRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<RideRequest> createRideRequest(RideRequest request) async {
    try {
      developer.log('🔄 Creando solicitud de viaje en el repositorio...', 
          name: 'RideRepositoryImpl');
    // Convierte la entidad del dominio a modelo de datos
    // Esto es necesario porque el datasource trabaja con modelos, no entidades
      final rideModel = RideRequestModel(
        origenLat: request.origenLat,
        origenLng: request.origenLng,
        destinoLat: request.destinoLat,
        destinoLng: request.destinoLng,
        origenDireccion: request.origenDireccion,
        destinoDireccion: request.destinoDireccion,
        precioSugerido: request.precioSugerido,
        notas: request.notas,
        metodoPagoPreferido: request.metodoPagoPreferido,
      );
    // Delega la operación al datasource remoto y retorna el resultado
    // El resultado ya es un RideModel, que es también un RideRequestEntity
      final result = await _remoteDataSource.createRideRequest(rideModel);
      developer.log('✅ Solicitud de viaje creada exitosamente en el repositorio', 
          name: 'RideRepositoryImpl');
      return result;
    } on ApiException catch (e) {
      developer.log('❌ Error en el repositorio: ${e.message}', 
          name: 'RideRepositoryImpl');
      rethrow;
    }
  }

  @override
  Future<RideRequest> getRideRequest(String id) async {
    try {
      developer.log('🔍 Obteniendo detalles del viaje $id en el repositorio...', 
          name: 'RideRepositoryImpl');
      
      final result = await _remoteDataSource.getRideRequest(id);
      developer.log('✅ Detalles del viaje obtenidos exitosamente en el repositorio', 
          name: 'RideRepositoryImpl');
      return result;
    } on ApiException catch (e) {
      developer.log('❌ Error al obtener detalles del viaje: ${e.message}', 
          name: 'RideRepositoryImpl');
      rethrow;
    }
  }

  @override
  Future<List<RideRequest>> getActiveRideRequests() async {
    try {
      developer.log('📋 Obteniendo viajes activos en el repositorio...', 
          name: 'RideRepositoryImpl');
      
      final result = await _remoteDataSource.getActiveRideRequests();
      developer.log('✅ ${result.length} viajes activos obtenidos en el repositorio', 
          name: 'RideRepositoryImpl');
      return result;
    } on ApiException catch (e) {
      developer.log('❌ Error al obtener viajes activos: ${e.message}', 
          name: 'RideRepositoryImpl');
      rethrow;
    }
  }

  @override
  Future<void> cancelRideRequest(String id) async {
    try {
      developer.log('❌ Cancelando viaje $id en el repositorio...', 
          name: 'RideRepositoryImpl');
      
      await _remoteDataSource.cancelRideRequest(id);
      developer.log('✅ Viaje cancelado exitosamente en el repositorio', 
          name: 'RideRepositoryImpl');
    } on ApiException catch (e) {
      developer.log('❌ Error al cancelar viaje: ${e.message}', 
          name: 'RideRepositoryImpl');
      rethrow;
    }
  }
} 