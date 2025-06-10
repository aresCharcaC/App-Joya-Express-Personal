import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:joya_express/core/network/api_exceptions.dart';
import 'package:joya_express/data/models/driver_response_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
/**
 * Servicio encargado de gestionar todas las operaciones de conductor
 */
class DriverRemoteDataSource {
  final ApiClient _apiClient;

  DriverRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Registra un nuevo conductor
  Future<DriverResponse> register({
    required String dni,
    required String nombreCompleto,
    required String telefono,
    required String password,
    required String placa,
    required String fotoBrevete,
    String? fotoPerfil,
    String? fotoLateral,
    DateTime? fechaExpiracionBrevete,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverRegister,
      {
        'dni': dni,
        'nombre_completo': nombreCompleto,
        'telefono': telefono,
        'password': password,
        'placa': placa,
        'foto_brevete': fotoBrevete,
        if (fotoPerfil != null) 'foto_perfil': fotoPerfil,
        if (fotoLateral != null) 'foto_lateral': fotoLateral,
        if (fechaExpiracionBrevete != null)
          'fecha_expiracion_brevete': fechaExpiracionBrevete.toIso8601String(),
      },
    );
    return DriverResponse.fromJson(response);
  }

  /// Login de conductor
  Future<DriverLoginResponse> login(String dni, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverLogin,
      {
        'dni': dni,
        'password': password,
      },
    );
    return DriverLoginResponse.fromJson(response);
  }

  /// Refrescar token automáticamente
  Future<void> refreshToken() async {
    try {
      await _apiClient.post(ApiEndpoints.refresh, {});
    } catch (e) {
      // Si no se puede refrescar, limpiar cookies
      await _apiClient.clearCookies();
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.driverLogout, {});
    } finally {
      // Siempre limpiar cookies locales
      await _apiClient.clearCookies();
    }
  }

  /// Obtener perfil del conductor
  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await _apiClient.get(ApiEndpoints.driverProfile);
    } catch (e) {
      // Si hay error 401, intentar refresh automático
      if (e is AuthException) {
        await refreshToken();
        return await _apiClient.get(ApiEndpoints.driverProfile);
      }
      rethrow;
    }
  }

  /// Actualizar perfil
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      return await _apiClient.put(ApiEndpoints.driverProfile, data);
    } catch (e) {
      if (e is AuthException) {
        await refreshToken();
        return await _apiClient.put(ApiEndpoints.driverProfile, data);
      }
      rethrow;
    }
  }

  /// Agregar vehículo
  Future<Map<String, dynamic>> addVehicle(Map<String, dynamic> data) async {
    try {
      return await _apiClient.post(ApiEndpoints.driverVehicles, data);
    } catch (e) {
      if (e is AuthException) {
        await refreshToken();
        return await _apiClient.post(ApiEndpoints.driverVehicles, data);
      }
      rethrow;
    }
  }

  /// Listar vehículos
  Future<List<dynamic>> getVehicles() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.driverVehicles);
      return response['data'] as List<dynamic>;
    } catch (e) {
      if (e is AuthException) {
        await refreshToken();
        final response = await _apiClient.get(ApiEndpoints.driverVehicles);
        return response['data'] as List<dynamic>;
      }
      rethrow;
    }
  }

  /// Subir/actualizar documentos
  Future<Map<String, dynamic>> uploadDocument(Map<String, dynamic> data) async {
    try {
      return await _apiClient.post(ApiEndpoints.driverDocuments, data);
    } catch (e) {
      if (e is AuthException) {
        await refreshToken();
        return await _apiClient.post(ApiEndpoints.driverDocuments, data);
      }
      rethrow;
    }
  }

  /// Actualizar ubicación
  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _apiClient.put(ApiEndpoints.driverLocation, {
        'lat': lat,
        'lng': lng,
      });
    } catch (e) {
      if (e is AuthException) {
        await refreshToken();
        await _apiClient.put(ApiEndpoints.driverLocation, {
          'lat': lat,
          'lng': lng,
        });
      } else {
        rethrow;
      }
    }
  }

  /// Cambiar disponibilidad
  Future<void> setAvailability(bool disponible) async {
    try {
      await _apiClient.put(ApiEndpoints.driverAvailability, {
        'disponible': disponible,
      });
    } catch (e) {
      if (e is AuthException) {
        await refreshToken();
        await _apiClient.put(ApiEndpoints.driverAvailability, {
          'disponible': disponible,
        });
      } else {
        rethrow;
      }
    }
  }

  /// Buscar conductores disponibles cerca
  Future<List<dynamic>> getAvailableDrivers(double lat, double lng, double radius) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.driverAvailability}?lat=$lat&lng=$lng&radius=$radius'
      );
      return response['data'] as List<dynamic>;
    } catch (e) {
      if (e is AuthException) {
        await refreshToken();
        final response = await _apiClient.get(
          '${ApiEndpoints.driverAvailability}?lat=$lat&lng=$lng&radius=$radius'
        );
        return response['data'] as List<dynamic>;
      }
      rethrow;
    }
  }
}