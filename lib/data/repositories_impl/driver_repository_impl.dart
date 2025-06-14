import 'package:dio/src/dio.dart';
import 'package:joya_express/data/models/driver_model.dart';
import 'package:joya_express/data/services/file_upload_service.dart';
import 'package:joya_express/domain/entities/driver_entity.dart';
import 'package:joya_express/domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_datasource.dart';
import '../datasources/driver_local_datasource.dart';
/**
 * Implementación del repositorio de conductores.
 * Maneja la lógica de negocio y la comunicación
 */
class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remote;
  final DriverLocalDataSource local;
  final FileUploadService fileUploadService;

  DriverRepositoryImpl(Dio dio, {
    required this.remote,
    required this.local,
    required this.fileUploadService, 
  });

  @override
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
  }) async {
    final response = await remote.register(
      dni: dni,
      nombreCompleto: nombreCompleto,
      telefono: telefono,
      password: password,
      placa: placa,
      fotoBrevete: fotoBrevete,
      fotoPerfil: fotoPerfil,
      fotoLateral: fotoLateral,
      fechaExpiracionBrevete: fechaExpiracionBrevete,
    );
    // response.conductor ya es un DriverModel, no necesita conversión
    final driverModel = response.conductor;
    await local.saveDriver(driverModel);
    return driverModel;
  }

  @override
  Future<DriverEntity> login(String dni, String password) async {
    final response = await remote.login(dni, password);
    // response.conductor ya es un DriverModel, no necesita conversión
    final driverModel = response.conductor;
    await local.saveDriver(driverModel);
    return driverModel;
  }

  @override
  Future<void> refreshToken() => remote.refreshToken();

  @override
  Future<void> logout() async {
    await remote.logout();
    await local.saveDriver(DriverModel(
      id: '',
      dni: '',
      nombreCompleto: '',
      telefono: '',
      fotoPerfil: null,
      estado: '',
      totalViajes: 0,
      ubicacionLat: null,
      ubicacionLng: null,
      disponible: false,
      fechaRegistro: null,
      fechaActualizacion: null,
      documentos: [],
      vehiculos: [],
      metodosPago: [],
      fechaExpiracionBrevete: null,
      contactoEmergencia: null,
    ));
  }

  @override
  Future<DriverEntity> getProfile() async {
    final profileMap = await remote.getProfile();
    // El perfil viene en profileMap['data'] (no 'conductor' en este endpoint)
    final data = profileMap['data'];
    final driverModel = DriverModel.fromJson(data);
    await local.saveDriver(driverModel);
    return driverModel;
  }

  @override
  Future<DriverEntity> updateProfile({
    String? nombreCompleto,
    String? telefono,
    String? fotoPerfil,
  }) async {
    final updated = await remote.updateProfile({
      if (nombreCompleto != null) 'nombre_completo': nombreCompleto,
      if (telefono != null) 'telefono': telefono,
      if (fotoPerfil != null) 'foto_perfil': fotoPerfil,
    });
    // El perfil actualizado viene en updated['data']['conductor']
    final data = updated['data']['conductor'];
    final driverModel = DriverModel.fromJson(data);
    await local.saveDriver(driverModel);
    return driverModel;
  }

  @override
  Future<String> uploadFile(String filePath, String type) async {
    return await fileUploadService.uploadFile(filePath, type);
  }

  @override
  Future<Map<String, dynamic>> addVehicle(Map<String, dynamic> data) =>
      remote.addVehicle(data);

  @override
  Future<List<dynamic>> getVehicles() => remote.getVehicles();

  @override
  Future<Map<String, dynamic>> uploadDocument(Map<String, dynamic> data) =>
      remote.uploadDocument(data);

  @override
  Future<void> updateLocation(double lat, double lng) =>
      remote.updateLocation(lat, lng);

  @override
  Future<void> setAvailability(bool disponible) =>
      remote.setAvailability(disponible);

  @override
  Future<List<dynamic>> getAvailableDrivers(
          double lat, double lng, double radius) =>
      remote.getAvailableDrivers(lat, lng, radius);
}