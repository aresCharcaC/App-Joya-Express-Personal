// lib/data/services/rides_service.dart
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/network/api_client.dart';
import '../models/user/ride_request_model.dart';

class RidesService {
  final ApiClient _apiClient;
  final Dio _dio;

  RidesService({ApiClient? apiClient, Dio? dio})
    : _apiClient = apiClient ?? ApiClient(),
      _dio = dio ?? Dio();

  /// 🧭 Obtener solicitudes cercanas al conductor
  Future<List<RideRequestModel>> getNearbyRequests() async {
    try {
      final response = await _apiClient.get('/api/rides/driver/nearby-requests');
      if (response['success'] == true) {
        final data = response['data'];
        final nearbyRequests = data['nearby_requests'] as List;
        return nearbyRequests
            .map((json) => RideRequestModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error obteniendo solicitudes: $e');
      return [];
    }
  }

  /// 📍 Actualizar ubicación del conductor en backend
  Future<bool> updateDriverLocation(double lat, double lng) async {
    try {
      print('📍 Actualizando ubicación: $lat, $lng');

      final response = await _apiClient.put('/api/rides/driver/location', {
        'lat': lat,
        'lng': lng,
      });

      if (response['success'] == true) {
        print('✅ Ubicación actualizada en Redis');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error actualizando ubicación: $e');
      return false;
    }
  }

  /// 🎯 Hacer oferta a una solicitud
  Future<bool> makeOffer({
    required String rideId,
    required double tarifa,
    required int tiempoEstimado,
    String? mensaje,
  }) async {
    try {
      print('💰 Haciendo oferta para viaje: $rideId');

      final response = await _apiClient.post('/api/rides/driver/offer', {
        'ride_id': rideId,
        'tarifa_propuesta': tarifa,
        'tiempo_estimado_llegada_minutos': tiempoEstimado,
        if (mensaje != null) 'mensaje': mensaje,
      });

      if (response['success'] == true) {
        print('✅ Oferta enviada exitosamente');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error enviando oferta: $e');
      throw Exception('Error al enviar oferta: $e');
    }
  }

  /// 🎯 Rechazar solicitud
  Future<bool> rejectRequest(String rideId) async {
    try {
      print('❌ Rechazando solicitud: $rideId');

      // Por ahora solo log, luego implementar endpoint si es necesario
      print('✅ Solicitud rechazada (solo local)');
      return true;
    } catch (e) {
      print('❌ Error rechazando solicitud: $e');
      return false;
    }
  }

  /// 📍 Obtener ubicación actual del dispositivo
  Future<Position?> getCurrentLocation() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permisos de ubicación denegados');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Permisos de ubicación denegados permanentemente');
        return null;
      }

      // Obtener ubicación
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
        '📍 Ubicación obtenida: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      print('❌ Error obteniendo ubicación: $e');
      return null;
    }
  }

  /// 🔄 Iniciar actualizaciones automáticas de ubicación
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Actualizar cada 10 metros
      ),
    );
  }
}
