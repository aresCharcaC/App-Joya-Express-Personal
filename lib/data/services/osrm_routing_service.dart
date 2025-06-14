// lib/data/services/osrm_routing_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../core/constants/route_constants.dart';
import './geocoding_service.dart';

/// Servicio de routing usando OSRM (Open Source Routing Machine)
/// Reemplaza trip_routing con una solución más robusta y confiable
class OSRMRoutingService {
  static final OSRMRoutingService _instance = OSRMRoutingService._internal();
  factory OSRMRoutingService() => _instance;
  OSRMRoutingService._internal();

  // Servidores OSRM públicos disponibles
  static const List<String> _osrmServers = [
    'https://router.project-osrm.org',
    'https://routing.openstreetmap.de',
  ];

  static const String _currentServer = 'https://router.project-osrm.org';

  /// Calcula una ruta vehicular entre dos puntos usando OSRM
  Future<TripEntity> calculateRoute(
    LocationEntity pickup,
    LocationEntity destination,
  ) async {
    try {
      print('🚗 Calculando ruta con OSRM...');
      print('📍 Desde: ${pickup.address ?? pickup.coordinates.toString()}');
      print(
        '📍 Hasta: ${destination.address ?? destination.coordinates.toString()}',
      );

      // Validaciones iniciales
      _validateCoordinates(pickup.coordinates, destination.coordinates);

      // Construir URL para OSRM
      final url = _buildOSRMUrl(pickup.coordinates, destination.coordinates);
      print('🔗 URL OSRM: $url');

      // Realizar petición HTTP
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'JoyaExpress/1.0.0',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Error del servidor OSRM: ${response.statusCode}');
      }

      // Parsear respuesta
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['code'] != 'Ok') {
        final message = data['message'] ?? 'Error desconocido de OSRM';
        throw Exception('OSRM Error: $message');
      }

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        throw Exception('No se encontraron rutas disponibles');
      }

      final route = routes.first as Map<String, dynamic>;

      // Extraer información de la ruta
      final geometry = route['geometry'] as String;
      final distance = (route['distance'] as num).toDouble(); // metros
      final duration = (route['duration'] as num).toDouble(); // segundos

      // Decodificar geometría (polyline)
      final routePoints = _decodePolyline(geometry);

      if (routePoints.isEmpty) {
        throw Exception('La ruta generada está vacía');
      }

      // Validar que la ruta es razonable
      _validateRoute(
        routePoints,
        pickup.coordinates,
        destination.coordinates,
        distance,
      );

      print('✅ Ruta OSRM calculada exitosamente');
      print('   Distancia: ${(distance / 1000).toStringAsFixed(2)} km');
      print('   Duración: ${(duration / 60).toStringAsFixed(0)} min');
      print('   Puntos: ${routePoints.length}');

      // Crear TripEntity
      return await _createTripEntity(
        routePoints,
        distance,
        duration,
        pickup,
        destination,
      );
    } catch (e) {
      print('❌ Error calculando ruta OSRM: $e');
      rethrow;
    }
  }

  /// Construye la URL para la API de OSRM
  String _buildOSRMUrl(LatLng pickup, LatLng destination) {
    final coordinates =
        '${pickup.longitude},${pickup.latitude};${destination.longitude},${destination.latitude}';

    return '$_currentServer/route/v1/driving/$coordinates'
        '?overview=full'
        '&geometries=polyline'
        '&steps=false'
        '&annotations=false'
        '&alternatives=false';
  }

  /// Decodifica una polyline de Google/OSRM a lista de coordenadas
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  /// Valida que las coordenadas sean correctas
  void _validateCoordinates(LatLng pickup, LatLng destination) {
    if (pickup.latitude.abs() > 90 ||
        pickup.longitude.abs() > 180 ||
        destination.latitude.abs() > 90 ||
        destination.longitude.abs() > 180) {
      throw Exception(RouteConstants.invalidCoordinatesError);
    }

    final distance = _calculateDistance(pickup, destination);
    if (distance < RouteConstants.minRouteDistanceKm) {
      throw Exception(RouteConstants.sameLocationError);
    }

    if (distance > RouteConstants.maxRouteDistanceKm) {
      throw Exception(RouteConstants.tooFarError);
    }
  }

  /// Valida que la ruta generada sea razonable
  void _validateRoute(
    List<LatLng> routePoints,
    LatLng pickup,
    LatLng destination,
    double distance,
  ) {
    if (routePoints.length < 2) {
      throw Exception('Ruta demasiado corta');
    }

    // Verificar que la ruta comience y termine cerca de los puntos solicitados
    final startDistance =
        _calculateDistance(routePoints.first, pickup) * 1000; // metros
    final endDistance =
        _calculateDistance(routePoints.last, destination) * 1000; // metros

    if (startDistance > 500) {
      // 500 metros de tolerancia
      throw Exception('La ruta no comienza cerca del punto de recogida');
    }

    if (endDistance > 500) {
      // 500 metros de tolerancia
      throw Exception('La ruta no termina cerca del destino');
    }

    // Verificar que la distancia de la ruta sea razonable comparada con la distancia directa
    final directDistance =
        _calculateDistance(pickup, destination) * 1000; // metros
    final routeRatio = distance / directDistance;

    if (routeRatio > 5.0) {
      // La ruta no debería ser más de 5 veces la distancia directa
      throw Exception(
        'La ruta es demasiado larga comparada con la distancia directa',
      );
    }
  }

  /// Crea TripEntity desde los datos de OSRM
  Future<TripEntity> _createTripEntity(
    List<LatLng> routePoints,
    double distanceMeters,
    double durationSeconds,
    LocationEntity pickup,
    LocationEntity destination,
  ) async {
    final distanceKm = distanceMeters / 1000;
    final durationMinutes = (durationSeconds / 60).round();

    // Actualizar direcciones si es necesario
    final updatedPickup = await _updateLocationWithAddress(
      pickup,
      routePoints.first,
    );
    final updatedDestination = await _updateLocationWithAddress(
      destination,
      routePoints.last,
    );

    return TripEntity(
      routePoints: routePoints,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      pickup: updatedPickup,
      destination: updatedDestination,
      calculatedAt: DateTime.now(),
      routingEngine: 'OSRM',
      metadata: {
        'server': _currentServer,
        'originalDistance': distanceMeters,
        'originalDuration': durationSeconds,
      },
    );
  }

  /// Actualiza una ubicación con dirección real si es necesario
  Future<LocationEntity> _updateLocationWithAddress(
    LocationEntity original,
    LatLng routePoint,
  ) async {
    try {
      final distance = _calculateDistance(original.coordinates, routePoint);

      if (distance > 0.01) {
        // Si está a más de 10 metros
        final newAddress = await GeocodingService.getStreetNameFromCoordinates(
          routePoint,
        );

        return original.copyWith(
          coordinates: routePoint,
          address: newAddress ?? original.address,
          isSnappedToRoad: true,
        );
      }

      return original.copyWith(coordinates: routePoint, isSnappedToRoad: true);
    } catch (e) {
      print('Error actualizando dirección: $e');
      return original.copyWith(coordinates: routePoint, isSnappedToRoad: true);
    }
  }

  /// Ajusta un punto a la carretera más cercana usando OSRM
  Future<LatLng> snapToRoad(LatLng point) async {
    try {
      // OSRM Nearest service para encontrar el punto más cercano en la red de carreteras
      final url =
          '$_currentServer/nearest/v1/driving/${point.longitude},${point.latitude}?number=1';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'JoyaExpress/1.0.0',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['code'] == 'Ok') {
          final waypoints = data['waypoints'] as List?;
          if (waypoints != null && waypoints.isNotEmpty) {
            final waypoint = waypoints.first as Map<String, dynamic>;
            final location = waypoint['location'] as List;

            return LatLng(location[1], location[0]); // OSRM devuelve [lng, lat]
          }
        }
      }

      // Si no se puede ajustar, devolver el punto original
      return point;
    } catch (e) {
      print('Error ajustando punto a carretera: $e');
      return point;
    }
  }

  /// Verifica si un punto está cerca de una carretera
  Future<bool> isNearRoad(LatLng point) async {
    try {
      final snappedPoint = await snapToRoad(point);
      final distance = _calculateDistance(point, snappedPoint) * 1000; // metros

      // Si el punto ajustado está a menos de 100 metros, consideramos que está cerca de una carretera
      return distance < 100;
    } catch (e) {
      print('Error verificando si está cerca de carretera: $e');
      return false;
    }
  }

  /// Calcula distancia entre dos puntos en kilómetros usando fórmula de Haversine
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371;

    final lat1Rad = point1.latitude * (pi / 180);
    final lat2Rad = point2.latitude * (pi / 180);
    final deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    final a =
        pow(sin(deltaLatRad / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(deltaLngRad / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
