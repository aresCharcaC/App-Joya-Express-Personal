import '../entities/user_entity.dart';
import '../../data/models/auth_response_model.dart';
/**
 * Define los métodos que el repositorio de autenticación debe implementar
 */
abstract class AuthRepository {
  Future<SendCodeResponse> sendCode(String phone);
  Future<VerifyCodeResponse> verifyCode(String phone, String code);
  Future<UserEntity> register({
    required String phone,
    required String tempToken,
    required String password,
    required String fullName,
    String? email,
    String? profilePhoto,
  });
  Future<UserEntity> login(String phone, String password);
  Future<void> forgotPassword(String phone);
  Future<void> resetPassword(String phone, String code, String newPassword);
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
  Future<bool> refreshToken();
}