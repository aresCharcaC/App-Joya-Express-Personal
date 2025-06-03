import '../../domain/entities/user_entity.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/**
 * DATASOURCE TEMPORAL MOCK - Simula backend sin internet
 * SOLO PARA DESARROLLO - QUITAR DESPUÉS
 */
class AuthMockDataSource {
  /// Simular envío de código
  Future<SendCodeResponse> sendCode(String phone) async {
    // Simular delay de red
    await Future.delayed(Duration(seconds: 1));

    print('MOCK: Enviando código a $phone');

    return SendCodeResponse(
      telefono: phone,
      whatsapp: WhatsappInfo(
        number: phone,
        message: "Tu código de verificación MOCK es: 123456",
        url:
            "https://wa.me/${phone.replaceAll('+', '')}?text=Tu%20código%20es:%20123456",
      ),
      instructions: ["Código MOCK enviado", "Usa: 123456"],
      provider: "mock_temporal",
      timestamp: DateTime.now(),
    );
  }

  /// Simular verificación de código
  Future<VerifyCodeResponse> verifyCode(String phone, String code) async {
    await Future.delayed(Duration(seconds: 1));

    print('MOCK: Verificando código $code para $phone');

    // Aceptar cualquier código para desarrollo
    return VerifyCodeResponse(
      message: "Código MOCK verificado",
      tempToken: "mock_temp_token_${DateTime.now().millisecondsSinceEpoch}",
      telefono: phone,
      userExists: false,
    );
  }

  /// Simular registro
  Future<UserModel> register({
    required String phone,
    required String tempToken,
    required String password,
    required String fullName,
    String? email,
    String? profilePhoto,
  }) async {
    await Future.delayed(Duration(seconds: 1));

    print('MOCK: Registrando usuario $fullName');

    return UserModel(
      id: "mock_user_${DateTime.now().millisecondsSinceEpoch}",
      telefono: phone,
      nombreCompleto: fullName,
      email: email ?? 'mock@ejemplo.com',
      fotoPerfil: profilePhoto ?? "https://via.placeholder.com/150",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Simular login
  Future<UserModel> login(String phone, String password) async {
    await Future.delayed(Duration(seconds: 1));

    print('MOCK: Login $phone');

    return UserModel(
      id: "mock_user_login",
      telefono: phone,
      nombreCompleto: "Usuario Mock",
      email: "mock@ejemplo.com",
      fotoPerfil: "https://via.placeholder.com/150",
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  /// Simular recuperar contraseña
  Future<void> forgotPassword(String phone) async {
    await Future.delayed(Duration(seconds: 1));
    print('MOCK: Código de recuperación enviado a $phone');
  }

  /// Simular reset contraseña
  Future<void> resetPassword(
    String phone,
    String code,
    String newPassword,
  ) async {
    await Future.delayed(Duration(seconds: 1));
    print('MOCK: Contraseña reseteada para $phone');
  }

  /// Simular obtener usuario actual
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(Duration(milliseconds: 500));

    return UserModel(
      id: "mock_current_user",
      telefono: "+51987654321",
      nombreCompleto: "Usuario Actual Mock",
      email: "usuario@ejemplo.com",
      fotoPerfil: "https://via.placeholder.com/150",
      createdAt: DateTime.now().subtract(Duration(days: 15)),
      updatedAt: DateTime.now(),
    );
  }

  /// Simular logout
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 300));
    print('MOCK: Logout exitoso');
  }

  /// Simular refresh token
  Future<bool> refreshToken() async {
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }
}
