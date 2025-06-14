class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorType;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorType,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException({String? message}) 
    : super(message: message ?? 'Error de conexión a internet');
}

class ServerException extends ApiException {
  ServerException({String? message, super.statusCode}) 
    : super(
        message: message ?? 'Error del servidor'
      );
}

class AuthException extends ApiException {
  AuthException({String? message}) 
    : super(message: message ?? 'Error de autenticación');
}

class ValidationException extends ApiException {
  ValidationException({String? message}) 
    : super(message: message ?? 'Datos inválidos');
}