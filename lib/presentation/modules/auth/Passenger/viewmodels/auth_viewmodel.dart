import 'package:flutter/foundation.dart';
import 'package:joya_express/data/services/auth_persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../domain/entities/user_entity.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../data/models/auth_response_model.dart';
import '../../../../../shared/utils/phone_formatter.dart';
enum AuthState { initial, loading, success, error }
/**
 * ViewModel para manejar la lógica de autenticación
 */
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // Variables para almacenar datos de usuario
  String? _profilePhotoPath;
  String? get profilePhotoPath => _profilePhotoPath;

  // Estados
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  UserEntity? _currentUser;
  SendCodeResponse? _sendCodeResponse;
  VerifyCodeResponse? _verifyCodeResponse;
  String? _currentPhone;
  String? _tempPassword;
  String? get tempPassword => _tempPassword;

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserEntity? get currentUser => _currentUser;
  SendCodeResponse? get sendCodeResponse => _sendCodeResponse;
  VerifyCodeResponse? get verifyCodeResponse => _verifyCodeResponse;
  String? get currentPhone => _currentPhone;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _currentUser != null;

  // URLs predefinidas para diferentes tipos de usuarios
  static const List<String> _defaultProfilePhotos = [
    'https://images.icon-icons.com/2483/PNG/512/user_icon_149851.png',
  ];
  
  // Inicializar desde estado persistido con validación
  Future<void> initializeFromPersistedState() async {
    try {
      final isValid = await AuthPersistenceService.isStateValid();
      if (!isValid) {
        print('AuthFlow - Estado expirado, limpiando...');
        await AuthPersistenceService.clearAuthFlowState();
        return;
      }

      final authState = await AuthPersistenceService.getAuthFlowState();
      
      if (authState['phoneNumber'] != null) {
        _currentPhone = authState['phoneNumber'];
        print('AuthFlow - Teléfono recuperado: $_currentPhone');
      }
      
      if (authState['tempToken'] != null) {
        // Recrear VerifyCodeResponse si existe el token
        _verifyCodeResponse = VerifyCodeResponse(
          tempToken: authState['tempToken']!,
          message: authState['message'] ?? '',
          telefono: authState['telefono'] ?? '',
          userExists: authState['userExists'] == true,
        );
        print('AuthFlow - Token temporal recuperado');
      }
      
      notifyListeners();
    } catch (e) {
      print('AuthFlow - Error al inicializar: $e');
      await AuthPersistenceService.clearAuthFlowState();
    }
  }


  // Enviar código de verificación
  Future<bool> sendVerificationCode(String phone) async {
    try {
      _setState(AuthState.loading);
      
      final formattedPhone = PhoneFormatter.formatToInternational(phone);
      _currentPhone = formattedPhone;
      
      _sendCodeResponse = await _authRepository.sendCode(formattedPhone);
      
      // Guardar inmediatamente después del envío exitoso
      await AuthPersistenceService.saveAuthFlowState(
        phoneNumber: formattedPhone,
        currentStep: 'code_sent',
      );
      
      print('AuthFlow - Código enviado y estado guardado para: $formattedPhone');
      _setState(AuthState.success);
      return true;
    } catch (e) {
      print('AuthFlow - Error enviando código: $e');
      _setError(e.toString());
      return false;
    }
  }

  // Verificar código
   Future<bool> verifyCode(String code) async {
    try {
      // Asegurar que tenemos los datos necesarios
      await _ensureAuthData();
      
      if (_currentPhone == null) {
        _setError('No se encontró el número de teléfono. Reinicia el proceso.');
        return false;
      }

      _setState(AuthState.loading);
      print('AuthFlow - Verificando código para: $_currentPhone');
      
      _verifyCodeResponse = await _authRepository.verifyCode(_currentPhone!, code);
      
      // Guardar token inmediatamente
      await AuthPersistenceService.saveAuthFlowState(
        phoneNumber: _currentPhone!,
        tempToken: _verifyCodeResponse?.tempToken,
        currentStep: 'code_verified',
      );
      
      print('AuthFlow - Código verificado y token guardado');
      _setState(AuthState.success);
      return true;
    } catch (e) {
      print('AuthFlow - Error verificando código: $e');
      _setError(e.toString());
      return false;
    }
  }

  // Asegurar que tenemos todos los datos necesarios
  Future<void> _ensureAuthData() async {
    if (_currentPhone == null || _verifyCodeResponse?.tempToken == null) {
      print('AuthFlow - Datos faltantes, recuperando de persistencia...');
      await initializeFromPersistedState();
    }
  }

  /// Determina si una ruta es local (archivo del dispositivo)
  bool _isLocalPath(String? path) {
    if (path == null) return false;
    return path.startsWith('/') || 
           path.startsWith('file://') || 
           path.contains('cache') ||
           path.contains('documents') ||
           path.contains('storage');
  }
  /// Obtiene una URL predefinida aleatoria o basada en el nombre
  String _getDefaultProfilePhotoUrl(String? fullName) {
    if (fullName == null || fullName.isEmpty) {
      return _defaultProfilePhotos.first;
    }
    
    // Usar el hash del nombre para obtener consistencia
    final hash = fullName.hashCode.abs();
    final index = hash % _defaultProfilePhotos.length;
    return _defaultProfilePhotos[index];
  }

  /// Guarda la imagen de perfil localmente para la UI
  void saveProfilePhoto(String path) {
    _profilePhotoPath = path;
    notifyListeners();
  }


  // Registrar con manejo completo de imagen y persistencia
  Future<bool> register({
    required String password,
    required String fullName,
    String? email,
    String? profilePhoto,
  }) async {
    try {
      // Asegurar datos necesarios
      await _ensureAuthData();
      
      if (_currentPhone == null || _verifyCodeResponse?.tempToken == null) {
        _setError('Faltan datos de verificación. Reinicia el proceso.');
        return false;
      }

      _setState(AuthState.loading);
      
      // Manejar imagen de perfil
      String? photoUrlForBackend;
      if (profilePhoto != null && _isLocalPath(profilePhoto)) {
        photoUrlForBackend = _getDefaultProfilePhotoUrl(fullName);
        print('AuthFlow - Imagen local detectada, usando URL predefinida: $photoUrlForBackend');
      } else if (profilePhoto != null) {
        photoUrlForBackend = profilePhoto;
      } else {
        photoUrlForBackend = _getDefaultProfilePhotoUrl(fullName);
      }
      
      print('AuthFlow - Registrando usuario con phone: $_currentPhone, token: ${_verifyCodeResponse!.tempToken}');
      
      _currentUser = await _authRepository.register(
        phone: _currentPhone!,
        tempToken: _verifyCodeResponse!.tempToken,
        password: password,
        fullName: fullName,
        email: email,
        profilePhoto: photoUrlForBackend,
      );
      
      // Limpiar estado después del registro exitoso
      await AuthPersistenceService.clearAuthFlowState();
      
      print('AuthFlow - Usuario registrado exitosamente');
      _setState(AuthState.success);
      return true;
    } catch (e) {
      print('AuthFlow - Error en registro: $e');
      _setError(e.toString());
      return false;
    }
  }

  // Iniciar sesión
  Future<bool> login(String phone, String password) async {
    try {
      _setState(AuthState.loading);
      
      final formattedPhone = PhoneFormatter.formatToInternational(phone);
      _currentPhone = formattedPhone;
      
      _currentUser = await _authRepository.login(formattedPhone, password);
      
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Recuperar contraseña
  Future<bool> forgotPassword(String phone) async {
    try {
      _setState(AuthState.loading);
      
      final formattedPhone = PhoneFormatter.formatToInternational(phone);
      await _authRepository.forgotPassword(formattedPhone);
      
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Resetear contraseña
  Future<bool> resetPassword(String phone, String code, String newPassword) async {
    try {
      _setState(AuthState.loading);
      
      final formattedPhone = PhoneFormatter.formatToInternational(phone);
      await _authRepository.resetPassword(formattedPhone, code, newPassword);
      
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Cargar usuario actual
  Future<void> loadCurrentUser() async {
    try {
      _setState(AuthState.loading);
      _currentUser = await _authRepository.getCurrentUser();
      _setState(_currentUser != null ? AuthState.success : AuthState.initial);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      _setState(AuthState.loading);
      await _authRepository.logout();
      _currentUser = null;
      _currentPhone = null;
      _sendCodeResponse = null;
      _verifyCodeResponse = null;

      // Limpiar también la persistencia
      await AuthPersistenceService.clearAuthFlowState();
      _setState(AuthState.initial);
    } catch (e) {
      _setError(e.toString());
    }
  }
  //Guardar imagen de perfil
  // Método duplicado eliminado para evitar conflicto de nombres.
  // Guardar contraseña temporal
   void saveTempPassword(String password) {
    _tempPassword = password;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helpers privados
  void _setState(AuthState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }
// Establecer error
  void _setError(String error) {
    _state = AuthState.error;
    _errorMessage = error;
    notifyListeners();
  }
}