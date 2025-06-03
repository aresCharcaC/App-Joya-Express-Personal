import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/location_entity.dart';
import 'geocoding_service.dart';

/// Servicio actualizado para manejo de ubicación y GPS
class LocationService {
  /// Obtiene la ubicación actual del usuario
  Future<LocationEntity?> getCurrentLocation() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permisos de ubicación denegados');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permisos de ubicación denegados permanentemente');
        return null;
      }

      // Obtener posición
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Intentar obtener nombre de calle real
      String? streetName = await GeocodingService.getStreetNameFromCoordinates(
        LatLng(position.latitude, position.longitude),
      );

      return LocationEntity(
        coordinates: LatLng(position.latitude, position.longitude),
        address: streetName,
        name: streetName ?? 'Mi ubicación',
        isCurrentLocation: true,
      );
    } catch (e) {
      print("Error obteniendo ubicación: $e");
      // Ubicación por defecto en Arequipa si falla GPS
      return LocationEntity(
        coordinates: const LatLng(-16.4090, -71.5375),
        address: 'Arequipa, Perú',
        name: 'Ubicación por defecto',
        isCurrentLocation: false,
      );
    }
  }

  /// Convierte un punto del mapa a ubicación con dirección real
  Future<LocationEntity> coordinatesToLocation(LatLng coordinates) async {
    try {
      // Obtener nombre real de la calle
      String? streetName = await GeocodingService.getStreetNameFromCoordinates(
        coordinates,
      );

      return LocationEntity(
        coordinates: coordinates,
        address: streetName,
        name: streetName,
        isCurrentLocation: false,
      );
    } catch (e) {
      print("Error obteniendo dirección: $e");
      return LocationEntity(
        coordinates: coordinates,
        address: null,
        name: 'Ubicación seleccionada',
        isCurrentLocation: false,
      );
    }
  }

  /// Obtiene nombre de calle sin crear LocationEntity
  Future<String?> getStreetName(LatLng coordinates) async {
    return await GeocodingService.getStreetNameFromCoordinates(coordinates);
  }
}
