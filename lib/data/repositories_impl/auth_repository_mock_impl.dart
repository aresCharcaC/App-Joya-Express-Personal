import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_mock_datasource.dart';
import '../models/auth_response_model.dart';

/**
 * REPOSITORIO TEMPORAL MOCK - Usa datos simulados
 * SOLO PARA DESARROLLO - REEMPLAZAR POR AuthRepositoryImpl después
 */
class AuthRepositoryMockImpl implements AuthRepository {
  final AuthMockDataSource _mockDataSource = AuthMockDataSource();
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryMockImpl({required AuthLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<SendCodeResponse> sendCode(String phone) async {
    final response = await _mockDataSource.sendCode(phone);
    await _localDataSource.savePhoneNumber(phone);
    return response;
  }

  @override
  Future<VerifyCodeResponse> verifyCode(String phone, String code) async {
    final response = await _mockDataSource.verifyCode(phone, code);
    await _localDataSource.saveTempToken(response.tempToken);
    return response;
  }

  @override
  Future<UserEntity> register({
    required String phone,
    required String tempToken,
    required String password,
    required String fullName,
    String? email,
    String? profilePhoto,
  }) async {
    final userModel = await _mockDataSource.register(
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

  @override
  Future<UserEntity> login(String phone, String password) async {
    final userModel = await _mockDataSource.login(phone, password);
    await _localDataSource.saveUser(userModel);
    return _mapToEntity(userModel);
  }

  @override
  Future<void> forgotPassword(String phone) async {
    await _mockDataSource.forgotPassword(phone);
  }

  @override
  Future<void> resetPassword(
    String phone,
    String code,
    String newPassword,
  ) async {
    await _mockDataSource.resetPassword(phone, code, newPassword);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final localUser = await _localDataSource.getUser();
    if (localUser != null) {
      return _mapToEntity(localUser);
    }

    try {
      final remoteUser = await _mockDataSource.getCurrentUser();
      await _localDataSource.saveUser(remoteUser);
      return _mapToEntity(remoteUser);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _mockDataSource.logout();
    } catch (e) {
      // Continuar con logout local
    }
    await _localDataSource.clearAll();
  }

  @override
  Future<bool> refreshToken() async {
    return await _mockDataSource.refreshToken();
  }

  /// Convertir modelo a entidad
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
