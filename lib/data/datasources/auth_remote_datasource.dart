import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../models/api_response_model.dart';

/**
 * Servicio encargado de gestionar todas las operaciones de autenticación 
 * que requieren comunicación remota con el backend
 */
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  /// Constructor que permite inyectar un ApiClient personalizado (útil para testing)
  AuthRemoteDataSource({ApiClient? apiClient}) 
    : _apiClient = apiClient ?? ApiClient();

  /// Envía un código de verificación al número de teléfono proporcionado.
  Future<SendCodeResponse> sendCode(String phone) async {
    final response = await _apiClient.post(
      ApiEndpoints.sendCode,
      {'telefono': phone},
    );
    
    final apiResponse = ApiResponse.fromJson(response, null);
    return SendCodeResponse.fromJson(response);
  }
    /// Verifica el código recibido por el usuario para el número de teléfono dado.
  Future<VerifyCodeResponse> verifyCode(String phone, String code) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyCode,
      {
        'telefono': phone,
        'codigo': code,
      },
    );
    
    return VerifyCodeResponse.fromJson(response);
  }
  /// Registra un nuevo usuario con los datos proporcionados.
  Future<UserModel> register({
    required String phone,
    required String tempToken,
    required String password,
    required String fullName,
    String? email,
    String? profilePhoto,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      {
        'telefono': phone,
        'tempToken': tempToken,
        'password': password,
        'nombre_completo': fullName,
        if (email != null) 'email': email,
        if (profilePhoto != null) 'foto_perfil': profilePhoto,
      },
    );
    
    final loginResponse = LoginResponse.fromJson(response);
    return loginResponse.user;
  }
    /// Inicia sesión con el número de teléfono y contraseña.
  Future<UserModel> login(String phone, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      {
        'telefono': phone,
        'password': password,
      },
    );
    
    final loginResponse = LoginResponse.fromJson(response);
    return loginResponse.user;
  }
  /// Solicita el envío de un código para recuperar la contraseña.
  Future<void> forgotPassword(String phone) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      {'telefono': phone},
    );
  }
  /// Restablece la contraseña usando el código recibido y la nueva contraseña.
  Future<void> resetPassword(String phone, String code, String newPassword) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword,
      {
        'telefono': phone,
        'codigo': code,
        'nuevaPassword': newPassword,
      },
    );
  }
  /// Obtiene los datos del usuario actualmente autenticado.
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.profile);
    return UserModel.fromJson(response['data'] ?? {});
  }
  /// Cierra la sesión del usuario en el backend.
  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout, {});
  }
  /// Refresca el token de autenticación.
  /// Retorna true si la operación fue exitosa.
  Future<bool> refreshToken() async {
    try {
      await _apiClient.post(ApiEndpoints.refresh, {});
      return true;
    } catch (e) {
      return false;
    }
  }
}