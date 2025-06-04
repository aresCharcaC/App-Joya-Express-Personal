class RouteConstants {
  RouteConstants._();

  // Timeouts para cálculo de rutas
  static const Duration routeCalculationTimeout = Duration(minutes: 3);

  // Configuración de rutas
  static const double maxRouteDistanceKm = 50.0;
  static const double minRouteDistanceKm = 0.1;

  // Velocidad promedio para mototaxis en Arequipa (km/h)
  static const double averageSpeed = 35.0;

  // Mensajes de error ACTUALIZADOS
  static const String noRouteFoundError =
      'No se pudo encontrar una ruta viable';
  static const String networkError = 'Error de conexión al calcular ruta';
  static const String timeoutError =
      'Tiempo de espera agotado al calcular ruta';
  static const String invalidCoordinatesError = 'Coordenadas inválidas';
  static const String tooFarError = 'La distancia es demasiado larga';
  static const String sameLocationError = 'Origen y destino son el mismo punto';
  static const String noRoadNearbyError = 'No hay calles vehiculares cercanas';

  // NUEVOS MENSAJES ESPECÍFICOS
  static const String noVehicleRouteError = 'No hay camino vehicular válido';
  static const String selectDifferentPointsError =
      'Selecciona otro punto de inicio y destino más cerca de calles principales';
  static const String pedestrianOnlyError =
      'Solo hay rutas peatonales disponibles en esta zona';
  static const String overpassBackupFailedError =
      'No se encontraron calles vehiculares en la zona seleccionada';

  // Configuración de polyline
  static const double routeStrokeWidth = 4.0;
  static const double routeStrokeWidthSelected = 6.0;

  // Límites geográficos de Arequipa (para optimización)
  static const double arequipaMinLat = -16.6;
  static const double arequipaMaxLat = -16.2;
  static const double arequipaMinLng = -71.8;
  static const double arequipaMaxLng = -71.3;

  /// Verifica si las coordenadas están dentro de Arequipa
  static bool isInArequipa(double lat, double lng) {
    return lat >= arequipaMinLat &&
        lat <= arequipaMaxLat &&
        lng >= arequipaMinLng &&
        lng <= arequipaMaxLng;
  }

  /// Calcula el tiempo estimado basado en la distancia
  static int calculateEstimatedTime(double distanceKm) {
    final hours = distanceKm / averageSpeed;
    return (hours * 60).round().clamp(1, 300); // Entre 1 y 300 minutos
  }
}
