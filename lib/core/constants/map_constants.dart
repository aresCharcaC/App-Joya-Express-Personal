import 'package:latlong2/latlong.dart';

class MapConstants {
  MapConstants._();

  // Configuración del mapa
  static const double defaultZoom = 15.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 18.0;

  // Ubicación por defecto (Plaza de Armas Arequipa)
  static const LatLng defaultLocation = LatLng(-16.398866, -71.536961);

  // URLs del mapa
  static const String mapTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgent = 'com.joyaexpress.app';

  // APIs de OpenStreetMap
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String photonBaseUrl = 'https://photon.komoot.io';

  // Configuración de marcadores
  static const double markerSize = 40.0;
  static const double routeStrokeWidth = 4.0;

  // Límites de Arequipa (para restringir búsquedas)
  static const LatLng arequipaNorthEast = LatLng(-16.290, -71.440);
  static const LatLng arequipaSouthWest = LatLng(-16.540, -71.640);

  // Textos del mapa
  static const String currentLocationText = 'Mi ubicación';
  static const String pickupLocationText = 'Punto de recogida';
  static const String destinationText = 'Destino';
  static const String searchDestinationPlaceholder = '¿A dónde vas?';
  static const String selectOnMapText = 'Seleccionar en el mapa';

  // Mensajes
  static const String locationPermissionDenied =
      'Permisos de ubicación denegados';
  static const String locationServiceDisabled =
      'Servicio de ubicación deshabilitado';
  static const String routeCalculationError = 'Error al calcular la ruta';
  static const String searchError = 'Error en la búsqueda';
}
