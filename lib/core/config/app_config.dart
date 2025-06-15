/**
 * Archivo de configuración de la aplicación.
 * Aquí definimos la URL base de la API y otros parámetros de configuración
 */
class AppConfig {
  static const String _defaultBaseUrl =
      'https://fd4e-38-255-105-31.ngrok-free.app'; //Actualizar diariamente

  static String get baseUrl {
    // Aquí podrías implementar lógica para obtener la URL desde:
    // - Variables de entorno
    // - Archivo de configuración
    // - API de configuración
    // - etc.
    return _defaultBaseUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);
}
