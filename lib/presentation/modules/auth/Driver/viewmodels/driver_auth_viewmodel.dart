// lib/presentation/viewmodels/driver_auth_viewmodel.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:joya_express/core/network/api_exceptions.dart';
import 'package:joya_express/domain/entities/driver_entity.dart';
import 'package:joya_express/domain/repositories/driver_repository.dart';
import 'package:joya_express/data/services/file_upload_service.dart';

/// ViewModel para la autenticación y gestión de conductores.
class DriverAuthViewModel extends ChangeNotifier {
  final DriverRepository _repository;
  final FileUploadService _fileUploadService;

  bool _isLoading = false;
  String? _error;
  DriverEntity? _currentDriver;
  bool _isAuthenticated = false;

  DriverAuthViewModel(this._repository, this._fileUploadService) {
    // Diagnóstico en constructor
    _diagnosticInit();
  }

  void _diagnosticInit() {
    print('=== DIAGNÓSTICO VIEWMODEL ===');
    print('Repository: ${_repository.runtimeType}');
    print('FileUploadService: ${_fileUploadService.runtimeType}');
    print('FileUploadService baseUrl: ${_fileUploadService.baseUrl}');
    print('============================');
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  DriverEntity? get currentDriver => _currentDriver;
  bool get isAuthenticated => _isAuthenticated;

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Verificar si hay sesión activa
  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final driver = await _repository.getProfile();
      _currentDriver = driver;
      _isAuthenticated = true;
      print('✅ Auth status verificado: Usuario autenticado');
    } catch (e) {
      _isAuthenticated = false;
      _currentDriver = null;
      print('ℹ️ Auth status: No hay sesión activa');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Subir archivo con diagnóstico mejorado
  Future<String?> uploadFile(String filePath, String type) async {
    try {
      print('=== INICIO DEBUG UPLOAD ===');
      print('Archivo: $filePath');
      print('Tipo: $type');
      print('FileUploadService baseUrl: ${_fileUploadService.baseUrl}');

      // Verificar que el archivo existe
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ ERROR: El archivo no existe en la ruta: $filePath');
        _setError('El archivo no existe');
        return null;
      }

      final fileSize = await file.length();
      print('📁 Tamaño del archivo: $fileSize bytes');

      if (fileSize == 0) {
        print('❌ ERROR: El archivo está vacío');
        _setError('El archivo está vacío');
        return null;
      }

      _setLoading(true);

      print('🚀 Iniciando upload...');
      final url = await _fileUploadService.uploadFile(filePath, type);

      if (url.isNotEmpty) {
        print('✅ Upload exitoso, URL: $url');
        print('=== FIN DEBUG UPLOAD ===');
        _setLoading(false);
        return url;
      } else {
        print('❌ Upload falló: URL vacía o nula');
        _setError('Error al subir archivo: respuesta vacía del servidor');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      print('=== ERROR EN UPLOAD ===');
      print('❌ Error: $e');
      print('❌ Tipo de error: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      _setError('Error al subir archivo: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  // Registro de conductor
  Future<bool> register({
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
    try {
      print('🔐 Iniciando registro de conductor...');
      _setLoading(true);
      clearError();

      final driver = await _repository.register(
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

      _currentDriver = driver;
      _isAuthenticated = true;
      _setLoading(false);
      print('✅ Registro exitoso');
      return true;
    } catch (e) {
      print('❌ Error en registro: $e');
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  // Login de conductor
  Future<bool> login(String dni, String password) async {
    try {
      print('🔐 Iniciando login...');
      _setLoading(true);
      clearError();

      final driver = await _repository.login(dni, password);
      _currentDriver = driver;
      _isAuthenticated = true;
      _setLoading(false);
      print('✅ Login exitoso');
      return true;
    } catch (e) {
      print('❌ Error en login: $e');
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  // Logout de conductor
  Future<void> logout() async {
    try {
      _setLoading(true);

      // Primero intentar hacer logout en el backend
      try {
        await _repository.logout();
        print('✅ Logout del backend exitoso');
      } catch (e) {
        // Si falla el logout del backend, continuar con el logout local
        print('⚠️ Error en logout del backend: $e');
      }

      // Siempre limpiar el estado local independientemente del resultado del backend
      _currentDriver = null;
      _isAuthenticated = false;
      clearError();
      print('✅ Logout local completado');
    } catch (e) {
      // Manejar cualquier error pero aún así limpiar el estado local
      print('❌ Error general en logout: $e');
      _currentDriver = null;
      _isAuthenticated = false;
      clearError();
    } finally {
      _setLoading(false);
    }
  }

  // Resto de métodos sin cambios...
  Future<void> getProfile() async {
    try {
      _setLoading(true);
      final driver = await _repository.getProfile();
      _currentDriver = driver;
      _isAuthenticated = true;
      _setLoading(false);
    } catch (e) {
      _handleError(e);
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? nombreCompleto,
    String? telefono,
    String? fotoPerfil,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final driver = await _repository.updateProfile(
        nombreCompleto: nombreCompleto,
        telefono: telefono,
        fotoPerfil: fotoPerfil,
      );

      _currentDriver = driver;
      _setLoading(false);
      return true;
    } catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addVehicle({
    required String placa,
    required String fotoLateral,
  }) async {
    try {
      _setLoading(true);
      clearError();

      await _repository.addVehicle({
        'placa': placa,
        'foto_lateral': fotoLateral,
      });

      await _refreshProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> uploadDocument({
    required String fotoBrevete,
    DateTime? fechaExpiracion,
  }) async {
    try {
      _setLoading(true);
      clearError();

      await _repository.uploadDocument({
        'foto_brevete': fotoBrevete,
        if (fechaExpiracion != null)
          'fecha_expiracion': fechaExpiracion.toIso8601String(),
      });

      await _refreshProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> setAvailability(bool disponible) async {
    try {
      _setLoading(true);
      clearError();

      // Las coordenadas son opcionales
      // El conductor puede cambiar disponibilidad sin GPS
      await _repository.setAvailability(disponible);

      if (_currentDriver != null) {
        _currentDriver = _currentDriver!.copyWith(disponible: disponible);
        notifyListeners();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateLocation(double lat, double lng) async {
    try {
      _setLoading(true);
      clearError();

      await _repository.updateLocation(lat, lng);

      if (_currentDriver != null) {
        _currentDriver = _currentDriver!.copyWith(
          ubicacionLat: lat,
          ubicacionLng: lng,
        );
        notifyListeners();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<List<dynamic>> getAvailableDrivers(
    double lat,
    double lng,
    double radius,
  ) async {
    try {
      _setLoading(true);
      clearError();

      final drivers = await _repository.getAvailableDrivers(lat, lng, radius);
      _setLoading(false);
      return drivers;
    } catch (e) {
      _handleError(e);
      _setLoading(false);
      return [];
    }
  }

  // Métodos auxiliares privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    String message = 'Error desconocido';

    if (error is ValidationException) {
      message = error.message;
    } else if (error is AuthException) {
      message = error.message;
      _currentDriver = null;
      _isAuthenticated = false;
    } else if (error is NetworkException) {
      message = error.message;
    } else if (error is ServerException) {
      message = 'Error del servidor. Por favor, intenta más tarde.';
    } else {
      message = error.toString();
    }

    _setError(message);
  }

  Future<void> _refreshProfile() async {
    try {
      final driver = await _repository.getProfile();
      _currentDriver = driver;
    } catch (e) {
      debugPrint('Error refrescando perfil: $e');
    }
  }
}
