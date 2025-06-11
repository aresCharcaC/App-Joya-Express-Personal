// lib/core/network/api_endpoints.dart
class ApiEndpoints {
  // ✅ MANTENER NOMBRES ORIGINALES - NO CAMBIAR

  // Base URL
  static const String baseUrl =
      'https://cafa-38-255-105-31.ngrok-free.app'; //Remplazar diariamente

  // ✅ MANTENER HEADERS ORIGINALES
  // Headers para peticiones JSON
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // Headers para peticiones multipart (SIN Content-Type)
  static const Map<String, String> multipartHeaders = {
    'ngrok-skip-browser-warning': 'true',
    // NO incluir Content-Type aquí, Dio lo maneja automáticamente
  };

  // Headers base (sin Content-Type)
  static const Map<String, String> baseHeaders = {
    'ngrok-skip-browser-warning': 'true',
  };

  // ✅ SOLO AGREGAR WebSocket URL SIN CAMBIAR NADA MÁS
  static String get websocketUrl {
    // Convertir HTTP a WebSocket
    if (baseUrl.startsWith('https://')) {
      return baseUrl.replaceFirst('https://', 'wss://');
    } else if (baseUrl.startsWith('http://')) {
      return baseUrl.replaceFirst('http://', 'ws://');
    }
    return 'wss://cafa-38-255-105-31.ngrok-free.app';
  }

  // ✅ MANTENER ENDPOINTS ORIGINALES EXISTENTES
  // Auth endpoints
  static const String sendCode = '/api/auth/send-code';
  static const String verifyCode = '/api/auth/verify-code';
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String profile = '/api/auth/profile';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';

  // Endpoints de conductores
  static const String driverRegister = '/api/conductor-auth/register';
  static const String driverLogin = '/api/conductor-auth/login';
  static const String driverProfile = '/api/conductor-auth/profile';
  static const String driverLogout = '/api/conductor-auth/logout';
  static const String driverVehicles = '/api/conductor-auth/vehicles';
  static const String driverDocuments = '/api/conductor-auth/documents';
  static const String driverLocation = '/api/conductor-auth/location';
  static const String driverAvailability = '/api/conductor-auth/availability';
  static const String driverUpload = '/api/conductor-auth/upload';

  // ✅ SOLO AGREGAR NUEVOS ENDPOINTS PARA SOLICITUDES
  // === NUEVOS ENDPOINTS PARA SOLICITUDES ===
  static const String nearbyRequests = '/api/rides/driver/nearby-requests';
  static const String updateDriverLocation = '/api/rides/driver/location';
  static const String makeDriverOffer = '/api/rides/driver/offer';
  static const String acceptRide = '/api/rides/driver/accept';
  static const String startRide = '/api/rides/driver/start';
  static const String endRide = '/api/rides/driver/end';
}
