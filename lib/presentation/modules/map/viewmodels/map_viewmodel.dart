import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../domain/entities/location_entity.dart';
import '../../../../data/services/location_service.dart';

/// Estados del mapa
enum MapState { loading, loaded, error }

/// ViewModel principal para manejo del estado del mapa
class MapViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  // Estado
  MapState _state = MapState.loading;
  String? _errorMessage;

  // Controlador del mapa
  final MapController mapController = MapController();

  // Ubicaciones
  LocationEntity? _currentLocation; // NUEVA: Ubicación actual (punto azul fijo)
  LocationEntity? _pickupLocation; // Pin negro móvil
  LocationEntity? _destinationLocation;

  // Configuración del mapa
  LatLng _currentCenter = const LatLng(
    -16.4090,
    -71.5375,
  ); // Arequipa por defecto
  double _currentZoom = 15.0;

  // Getters
  MapState get state => _state;
  String? get errorMessage => _errorMessage;
  LocationEntity? get currentLocation => _currentLocation; // NUEVO
  LocationEntity? get pickupLocation => _pickupLocation;
  LocationEntity? get destinationLocation => _destinationLocation;
  LatLng get currentCenter => _currentCenter;
  double get currentZoom => _currentZoom;

  // Getters de estado
  bool get isLoading => _state == MapState.loading;
  bool get hasError => _state == MapState.error;
  bool get isLoaded => _state == MapState.loaded;
  bool get hasCurrentLocation => _currentLocation != null; // NUEVO
  bool get hasPickupLocation => _pickupLocation != null;
  bool get hasDestinationLocation => _destinationLocation != null;
  bool get canCalculateRoute => hasPickupLocation && hasDestinationLocation;

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

  /// Establecer destino
  Future<void> setDestinationLocation(LocationEntity destination) async {
    _destinationLocation = destination;
    notifyListeners();

    // Calcular ruta automáticamente si hay origen y destino
    if (hasPickupLocation && hasDestinationLocation) {
      await calculateRoute();
    }
  }

  /// Establecer destino temporal (para preview en selección de mapa)
  void setDestinationLocationTemporary(LocationEntity destination) {
    _destinationLocation = destination;
    notifyListeners();
  }

  /// Calcular y mostrar ruta
  Future<void> calculateRoute() async {
    if (!canCalculateRoute) return;

    try {
      print(
        'Calculando ruta desde ${_pickupLocation!.address} hasta ${_destinationLocation!.address}',
      );

      // TODO: Aquí integrarías el VehicleTripService del test de tu amigo
      // Por ahora solo ajustamos el mapa para mostrar ambos puntos

      // Crear bounds que incluyan ambos puntos
      final points = [
        _pickupLocation!.coordinates,
        _destinationLocation!.coordinates,
      ];

      // Calcular centro y zoom para mostrar ambos puntos
      double minLat = points
          .map((p) => p.latitude)
          .reduce((a, b) => a < b ? a : b);
      double maxLat = points
          .map((p) => p.latitude)
          .reduce((a, b) => a > b ? a : b);
      double minLng = points
          .map((p) => p.longitude)
          .reduce((a, b) => a < b ? a : b);
      double maxLng = points
          .map((p) => p.longitude)
          .reduce((a, b) => a > b ? a : b);

      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;

      _currentCenter = LatLng(centerLat, centerLng);

      // Ajustar zoom basado en la distancia
      final latDiff = maxLat - minLat;
      final lngDiff = maxLng - minLng;
      final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

      if (maxDiff > 0.1) {
        _currentZoom = 10;
      } else if (maxDiff > 0.05) {
        _currentZoom = 12;
      } else if (maxDiff > 0.02) {
        _currentZoom = 13;
      } else {
        _currentZoom = 14;
      }

      // Mover mapa
      mapController.move(_currentCenter, _currentZoom);

      notifyListeners();
      print('Ruta calculada - Centro: $_currentCenter, Zoom: $_currentZoom');
    } catch (e) {
      print('Error calculando ruta: $e');
    }
  }

  /// Limpiar destino
  void clearDestination() {
    _destinationLocation = null;
    notifyListeners();
  }

  /// Limpiar ubicaciones
  void clearLocations() {
    _pickupLocation = null;
    _destinationLocation = null;
    notifyListeners();
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

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
