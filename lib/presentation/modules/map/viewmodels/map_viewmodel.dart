// lib/presentation/modules/map/viewmodels/map_viewmodel.dart (ACTUALIZADO)
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:math' as math;
import '../../../../domain/entities/location_entity.dart';
import '../../../../domain/entities/trip_entity.dart';
import '../../../../data/services/location_service.dart';
import '../../../../domain/repositories/routing_repository.dart';
import '../../../../data/repositories_impl/routing_repository_impl.dart';
import '../../../../core/constants/route_constants.dart';
import 'package:latlong2/latlong.dart';

/// Estados del mapa
enum MapState { loading, loaded, error }

/// Estados de cálculo de ruta
enum RouteState { idle, calculating, calculated, error }

/// ViewModel principal para manejo del estado del mapa con rutas
class MapViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final RoutingRepository _routingRepository = RoutingRepositoryImpl();

  // Estado general
  MapState _state = MapState.loading;
  String? _errorMessage;

  // Estado de rutas
  RouteState _routeState = RouteState.idle;
  String? _routeErrorMessage;
  TripEntity? _currentTrip;

  // Controlador del mapa
  final MapController mapController = MapController();

  // Ubicaciones
  LocationEntity? _currentLocation; // Ubicación actual (punto azul fijo)
  LocationEntity? _pickupLocation; // Pin negro móvil
  LocationEntity? _destinationLocation;

  // Configuración del mapa
  LatLng _currentCenter = const LatLng(
    -16.4090,
    -71.5375,
  ); // Arequipa por defecto
  double _currentZoom = 15.0;

  // Getters principales
  MapState get state => _state;
  String? get errorMessage => _errorMessage;
  RouteState get routeState => _routeState;
  String? get routeErrorMessage => _routeErrorMessage;
  TripEntity? get currentTrip => _currentTrip;

  LocationEntity? get currentLocation => _currentLocation;
  LocationEntity? get pickupLocation => _pickupLocation;
  LocationEntity? get destinationLocation => _destinationLocation;
  LatLng get currentCenter => _currentCenter;
  double get currentZoom => _currentZoom;

  // Getters de estado
  bool get isLoading => _state == MapState.loading;
  bool get hasError => _state == MapState.error;
  bool get isLoaded => _state == MapState.loaded;
  bool get hasCurrentLocation => _currentLocation != null;
  bool get hasPickupLocation => _pickupLocation != null;
  bool get hasDestinationLocation => _destinationLocation != null;
  bool get canCalculateRoute => hasPickupLocation && hasDestinationLocation;

  // Getters de ruta
  bool get isCalculatingRoute => _routeState == RouteState.calculating;
  bool get hasRoute =>
      _routeState == RouteState.calculated && _currentTrip != null;
  bool get hasRouteError => _routeState == RouteState.error;
  List<LatLng> get routePoints => _currentTrip?.routePoints ?? [];
  double get routeDistance => _currentTrip?.distanceKm ?? 0.0;
  int get routeDuration => _currentTrip?.durationMinutes ?? 0;

  /// Inicializar el mapa con la ubicación actual
  Future<void> initializeMap() async {
    try {
      _setState(MapState.loading);

      // Obtener ubicación actual
      final currentLoc = await _locationService.getCurrentLocation();

      if (currentLoc != null) {
        _currentLocation = currentLoc; // Punto azul fijo
        _pickupLocation =
            currentLoc
                .copyWith(); // Pin negro inicialmente en la misma ubicación
        _currentCenter = currentLoc.coordinates;

        // Centrar el mapa en la ubicación actual
        mapController.move(_currentCenter, _currentZoom);
      }

      _setState(MapState.loaded);
    } catch (e) {
      _setError('Error al inicializar el mapa: $e');
    }
  }

  /// Establecer punto de recogida tocando en el mapa (SOLO MUEVE EL PIN NEGRO)
  Future<void> setPickupLocationFromTap(LatLng coordinates) async {
    try {
      final location = await _locationService.coordinatesToLocation(
        coordinates,
      );
      _pickupLocation = location;

      // Limpiar ruta si existía
      _clearRoute();

      notifyListeners();
      print(
        'Punto de recogida establecido en: ${location.address ?? coordinates.toString()}',
      );
    } catch (e) {
      print('Error al establecer punto de recogida: $e');
    }
  }

  /// Establecer ubicación actual como punto de recogida (MOVER PIN NEGRO A PUNTO AZUL)
  Future<void> useCurrentLocationAsPickup() async {
    if (_currentLocation != null) {
      _pickupLocation = _currentLocation!.copyWith();
      mapController.move(_currentLocation!.coordinates, _currentZoom);

      // Limpiar ruta si existía
      _clearRoute();

      notifyListeners();
    }
  }

  /// Centrar mapa en ubicación actual
  void centerOnCurrentLocation() {
    if (_currentLocation != null) {
      mapController.move(_currentLocation!.coordinates, _currentZoom);
    }
  }

  /// Actualizar centro del mapa
  void updateMapCenter(LatLng center, double zoom) {
    _currentCenter = center;
    _currentZoom = zoom;
    // No notificamos aquí para evitar rebuilds constantes durante el movimiento
  }

  /// Establecer destino y calcular ruta automáticamente
  Future<void> setDestinationLocation(LocationEntity destination) async {
    _destinationLocation = destination;
    notifyListeners();

    // Calcular ruta automáticamente si hay origen y destino
    if (hasPickupLocation && hasDestinationLocation) {
      await calculateRoute();
    }
  }

  /// Calcular ruta vehicular
  Future<void> calculateRoute() async {
    if (!canCalculateRoute) return;

    try {
      _setRouteState(RouteState.calculating);

      print('🚗 Iniciando cálculo de ruta...');
      print(
        '📍 Desde: ${_pickupLocation!.address ?? _pickupLocation!.coordinates.toString()}',
      );
      print(
        '📍 Hasta: ${_destinationLocation!.address ?? _destinationLocation!.coordinates.toString()}',
      );

      // Calcular ruta usando el repositorio
      final trip = await _routingRepository.calculateVehicleRoute(
        _pickupLocation!,
        _destinationLocation!,
      );

      // Actualizar ubicaciones con las coordenadas ajustadas
      _pickupLocation = trip.pickup;
      _destinationLocation = trip.destination;
      _currentTrip = trip;

      // Ajustar vista del mapa para mostrar toda la ruta
      _fitRouteToMap();

      _setRouteState(RouteState.calculated);

      print('✅ Ruta calculada exitosamente:');
      print('   📏 ${trip.distanceKm.toStringAsFixed(2)} km');
      print('   ⏱️ ${trip.durationMinutes} minutos');
      print('   📍 ${trip.routePoints.length} puntos');
    } catch (e) {
      print('❌ Error calculando ruta: $e');
      _setRouteError(_getErrorMessage(e.toString()));
    }
  }

  /// Ajustar vista del mapa para mostrar toda la ruta
  void _fitRouteToMap() {
    if (_currentTrip == null || _currentTrip!.routePoints.isEmpty) return;

    try {
      final points = _currentTrip!.routePoints;

      // Calcular bounds de la ruta
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;

      for (final point in points) {
        minLat = math.min(minLat, point.latitude);
        maxLat = math.max(maxLat, point.latitude);
        minLng = math.min(minLng, point.longitude);
        maxLng = math.max(maxLng, point.longitude);
      }

      // Agregar padding
      const padding = 0.005; // ~500m aproximadamente
      minLat -= padding;
      maxLat += padding;
      minLng -= padding;
      maxLng += padding;

      // Calcular centro y zoom
      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;
      _currentCenter = LatLng(centerLat, centerLng);

      // Calcular zoom basado en la extensión
      final latDiff = maxLat - minLat;
      final lngDiff = maxLng - minLng;
      final maxDiff = math.max(latDiff, lngDiff);

      if (maxDiff > 0.05) {
        _currentZoom = 11;
      } else if (maxDiff > 0.02) {
        _currentZoom = 12;
      } else if (maxDiff > 0.01) {
        _currentZoom = 13;
      } else {
        _currentZoom = 14;
      }

      // Mover mapa
      mapController.move(_currentCenter, _currentZoom);
    } catch (e) {
      print('Error ajustando vista del mapa: $e');
    }
  }

  /// Limpiar ruta actual
  void clearRoute() {
    _clearRoute();
    notifyListeners();
  }

  /// Limpiar destino
  void clearDestination() {
    _destinationLocation = null;
    _clearRoute();
    notifyListeners();
  }

  /// Limpiar todas las ubicaciones
  void clearLocations() {
    _pickupLocation = null;
    _destinationLocation = null;
    _clearRoute();
    notifyListeners();
  }

  /// Reintenta el cálculo de ruta
  Future<void> retryRouteCalculation() async {
    if (canCalculateRoute) {
      await calculateRoute();
    }
  }

  /// Helpers privados
  void _setState(MapState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _state = MapState.error;
    _errorMessage = error;
    notifyListeners();
  }

  void _setRouteState(RouteState newState) {
    _routeState = newState;
    _routeErrorMessage = null;
    notifyListeners();
  }

  void _setRouteError(String error) {
    _routeState = RouteState.error;
    _routeErrorMessage = error;
    notifyListeners();
  }

  void _clearRoute() {
    _currentTrip = null;
    _routeState = RouteState.idle;
    _routeErrorMessage = null;
  }

  /// Obtener mensaje de error user-friendly
  String _getErrorMessage(String error) {
    if (error.contains(RouteConstants.timeoutError)) {
      return 'La conexión tardó demasiado. Intenta nuevamente.';
    } else if (error.contains(RouteConstants.networkError)) {
      return 'Sin conexión a internet. Verifica tu conexión.';
    } else if (error.contains(RouteConstants.noRouteFoundError)) {
      return 'No se encontró una ruta viable entre estos puntos.';
    } else if (error.contains(RouteConstants.noRoadNearbyError)) {
      return 'No hay calles cercanas. Selecciona otro punto.';
    } else if (error.contains(RouteConstants.tooFarError)) {
      return 'La distancia es demasiado larga.';
    } else if (error.contains(RouteConstants.sameLocationError)) {
      return 'El origen y destino son muy cercanos.';
    } else {
      return 'Error calculando la ruta. Intenta nuevamente.';
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
