import 'package:joya_express/domain/entities/driver_entity.dart';
// Define los métodos que el repositorio de conductores debe implementar
abstract class DriverRepository {
  Future<DriverEntity> register({
    required String dni,
    required String nombreCompleto,
    required String telefono,
    required String password,
    required String placa,
    required String fotoBrevete,
    String? fotoPerfil,
    String? fotoLateral,
    DateTime? fechaExpiracionBrevete,
  });

  Future<DriverEntity> login(String dni, String password);
  Future<void> refreshToken();
  Future<void> logout();
  Future<DriverEntity> getProfile();
  Future<DriverEntity> updateProfile({
    String? nombreCompleto,
    String? telefono,
    String? fotoPerfil,
  });
  Future<Map<String, dynamic>> addVehicle(Map<String, dynamic> data);
  Future<List<dynamic>> getVehicles();
  Future<Map<String, dynamic>> uploadDocument(Map<String, dynamic> data);
  Future<void> updateLocation(double lat, double lng);
  Future<void> setAvailability(bool disponible);
  Future<List<dynamic>> getAvailableDrivers(double lat, double lng, double radius);
}
