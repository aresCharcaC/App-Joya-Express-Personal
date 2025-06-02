import 'package:joya_express/core/network/api_client.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/auth_response_model.dart';

/**
 * Implementación del repositorio de autenticación.
 * Maneja la lógica de negocio y la comunicación 
 * con las fuentes de datos remotas y locales.
 */
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  /// Constructor con inyección de dependencias.
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required ApiClient apiClient,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  /// Envía un código de verificación al número de teléfono.
  /// Guarda el número localmente para persistencia.
  @override
  Future<SendCodeResponse> sendCode(String phone) async {
    final response = await _remoteDataSource.sendCode(phone);
    await _localDataSource.savePhoneNumber(phone);
    return response;
  }
  /// Verifica el código recibido por el usuario.
  /// Guarda el token temporal localmente si la verificación es exitosa.
  @override
  Future<VerifyCodeResponse> verifyCode(String phone, String code) async {
    final response = await _remoteDataSource.verifyCode(phone, code);
    await _localDataSource.saveTempToken(response.tempToken);
    return response;
  }
  /// Registra un nuevo usuario con los datos proporcionados.
  /// Guarda el usuario localmente tras el registro.
  @override
  Future<UserEntity> register({
    required String phone,
    required String tempToken,
    required String password,
    required String fullName,
    String? email,
    String? profilePhoto,
  }) async {
    final userModel = await _remoteDataSource.register(
      phone: phone,
      tempToken: tempToken,
      password: password,
      fullName: fullName,
      email: email,
      profilePhoto: profilePhoto,
    );

    await _localDataSource.saveUser(userModel);
    
    return _mapToEntity(userModel);
  }
  /// Inicia sesión con el número y contraseña.
  /// Guarda el usuario localmente tras el login

  @override
  Future<UserEntity> login(String phone, String password) async {
    final userModel = await _remoteDataSource.login(phone, password);
    await _localDataSource.saveUser(userModel);
    return _mapToEntity(userModel);
  }
  /// Solicita el envío de un código para recuperar la contraseña.

  @override
  Future<void> forgotPassword(String phone) async {
    await _remoteDataSource.forgotPassword(phone);
  }
  /// Restablece la contraseña usando el código recibido y la nueva contraseña.
  @override
  Future<void> resetPassword(String phone, String code, String newPassword) async {
    await _remoteDataSource.resetPassword(phone, code, newPassword);
  }
  /// Obtiene el usuario actual, primero localmente y si no existe, remotamente.
  /// Si lo obtiene remotamente, lo guarda localmente
  @override
  Future<UserEntity?> getCurrentUser() async {
    final localUser = await _localDataSource.getUser();
    if (localUser != null) {
      return _mapToEntity(localUser);
    }

    try {
      final remoteUser = await _remoteDataSource.getCurrentUser();
      await _localDataSource.saveUser(remoteUser);
      return _mapToEntity(remoteUser);
    } catch (e) {
      return null;
    }
  }

  /// Cierra la sesión del usuario, tanto en backend como localmente.

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      // Continuar con logout local aunque falle el remoto
    }
    await _localDataSource.clearAll();
  }
  /// Refresca el token de autenticación.
  @override
  Future<bool> refreshToken() async {
    return await _remoteDataSource.refreshToken();
  }

  /// Convierte un modelo de usuario a entidad de dominio.

  UserEntity _mapToEntity(userModel) {
    return UserEntity(
      id: userModel.id,
      phone: userModel.telefono,
      fullName: userModel.nombreCompleto,
      email: userModel.email,
      profilePhoto: userModel.fotoPerfil,
      createdAt: userModel.createdAt,
    );
  }
}