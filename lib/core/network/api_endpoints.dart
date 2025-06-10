class ApiEndpoints {
  // Base URL

  static const String baseUrl = 'https://7567-190-235-229-26.ngrok-free.app'; //Remplazar diariamente
  
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
  // Endpoint para subir archivos
  static const String driverUpload = '/api/conductor-auth/upload';
}
