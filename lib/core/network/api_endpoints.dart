class ApiEndpoints {
  // Base URL
  static const String baseUrl =
      'https://b8de-2a09-bac5-4f33-791-00-c1-84.ngrok-free.app'; //Remplazar diariamente

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

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };
}
