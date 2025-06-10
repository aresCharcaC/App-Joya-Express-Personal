import 'package:latlong2/latlong.dart';
import 'dart:math';
import '../../domain/entities/place_entity.dart';

/// Servicio para manejo de lugares guardados y búsqueda
class PlacesService {
  /// Base de datos en memoria de lugares populares de Arequipa
  static final List<PlaceEntity> _arequipaPlaces = [
    // Lugares turísticos
    PlaceEntity(
      id: 'plaza_armas',
      name: 'Plaza de Armas',
      description: 'Centro histórico de Arequipa',
      coordinates: const LatLng(-16.3989, -71.5370),
      category: 'Turístico',
      isPopular: true,
    ),
    PlaceEntity(
      id: 'monasterio_santa_catalina',
      name: 'Monasterio Santa Catalina',
      description: 'Monasterio histórico',
      coordinates: const LatLng(-16.3966, -71.5368),
      category: 'Turístico',
      isPopular: true,
    ),
    PlaceEntity(
      id: 'mirador_yanahuara',
      name: 'Mirador de Yanahuara',
      description: 'Vista panorámica de la ciudad',
      coordinates: const LatLng(-16.3925, -71.5447),
      category: 'Turístico',
      isPopular: true,
    ),

    // Centros comerciales
    PlaceEntity(
      id: 'real_plaza',
      name: 'Real Plaza Arequipa',
      description: 'Centro comercial',
      coordinates: const LatLng(-16.4091, -71.5240),
      category: 'Comercial',
      isPopular: true,
    ),
    PlaceEntity(
      id: 'saga_falabella',
      name: 'Saga Falabella',
      description: 'Tienda departamental',
      coordinates: const LatLng(-16.4090, -71.5240),
      category: 'Comercial',
      isPopular: true,
    ),
    PlaceEntity(
      id: 'mall_aventura',
      name: 'Mall Aventura Plaza',
      description: 'Centro comercial',
      coordinates: const LatLng(-16.4320, -71.5098),
      category: 'Comercial',
      isPopular: true,
    ),

    // Universidades
    PlaceEntity(
      id: 'unsa',
      name: 'Universidad Nacional San Agustín',
      description: 'UNSA - Campus principal',
      coordinates: const LatLng(-16.4030, -71.5290),
      category: 'Educación',
      isPopular: true,
    ),
    PlaceEntity(

      id: 'tecsup',
      name: 'TECSUP Arequipa',
      description: 'Instituto de Educación Superior TECSUP Arequipa',
      coordinates: const LatLng(-16.428664, -71.519649),
      category: 'Educación',
      isPopular: true,
    ),

    PlaceEntity(

      id: 'ucsm',
      name: 'Universidad Católica Santa María',
      description: 'UCSM - Campus principal',
      coordinates: const LatLng(-16.4150, -71.5320),
      category: 'Educación',
      isPopular: true,
    ),

    // Transporte
    PlaceEntity(
      id: 'terminal_terrestre',
      name: 'Terminal Terrestre',
      description: 'Terminal de buses',
      coordinates: const LatLng(-16.4200, -71.5300),
      category: 'Transporte',
      isPopular: true,
    ),
    PlaceEntity(
      id: 'aeropuerto',
      name: 'Aeropuerto Arequipa',
      description: 'Aeropuerto Alfredo Rodríguez Ballón',
      coordinates: const LatLng(-16.3411, -71.5830),
      category: 'Transporte',
      isPopular: true,
    ),

    // Mercados
    PlaceEntity(
      id: 'mercado_san_camilo',
      name: 'Mercado San Camilo',
      description: 'Mercado tradicional',
      coordinates: const LatLng(-16.3950, -71.5350),
      category: 'Mercado',
      isPopular: true,
    ),

    // Hospitales
    PlaceEntity(
      id: 'hospital_nacional',
      name: 'Hospital Nacional',
      description: 'Hospital Nacional Carlos Alberto Seguín Escobedo',
      coordinates: const LatLng(-16.4010, -71.5250),
      category: 'Salud',
      isPopular: true,
    ),
    PlaceEntity(
      id: 'hospital_goyeneche',
      name: 'Hospital Goyeneche',
      description: 'Hospital Honorio Delgado',
      coordinates: const LatLng(-16.4145, -71.5298),
      category: 'Salud',
      isPopular: true,
    ),

    // Avenidas principales
    PlaceEntity(
      id: 'av_ejercito',
      name: 'Av. Ejército',
      description: 'Avenida principal',
      coordinates: const LatLng(-16.4024, -71.5196),
      category: 'Avenida',
      isPopular: false,
    ),
    PlaceEntity(
      id: 'av_dolores',
      name: 'Av. Dolores',
      description: 'Avenida principal',
      coordinates: const LatLng(-16.4089, -71.5220),
      category: 'Avenida',
      isPopular: false,
    ),
    PlaceEntity(
      id: 'av_parra',
      name: 'Av. Parra',
      description: 'Avenida principal',
      coordinates: const LatLng(-16.4156, -71.5031),
      category: 'Avenida',
      isPopular: false,
    ),
    PlaceEntity(
      id: 'av_venezuela',
      name: 'Av. Venezuela',
      description: 'Avenida principal',
      coordinates: const LatLng(-16.4067, -71.5339),
      category: 'Avenida',
      isPopular: false,
    ),

    // Distritos
    PlaceEntity(
      id: 'cayma',
      name: 'Cayma',
      description: 'Distrito de Cayma',
      coordinates: const LatLng(-16.3850, -71.5420),
      category: 'Distrito',
      isPopular: false,
    ),
    PlaceEntity(
      id: 'cerro_colorado',
      name: 'Cerro Colorado',
      description: 'Distrito de Cerro Colorado',
      coordinates: const LatLng(-16.3700, -71.5800),
      category: 'Distrito',
      isPopular: false,
    ),
    PlaceEntity(
      id: 'paucarpata',
      name: 'Paucarpata',
      description: 'Distrito de Paucarpata',
      coordinates: const LatLng(-16.4300, -71.5100),
      category: 'Distrito',
      isPopular: false,
    ),
  ];

  /// Obtener todos los lugares
  List<PlaceEntity> getAllPlaces() {
    return List.from(_arequipaPlaces);
  }

  /// Obtener lugares populares
  List<PlaceEntity> getPopularPlaces() {
    return _arequipaPlaces.where((place) => place.isPopular).toList();
  }

  /// Buscar lugares por texto
  List<PlaceEntity> searchPlaces(String query) {
    if (query.trim().isEmpty) {
      return getPopularPlaces();
    }

    final queryLower = query.toLowerCase().trim();

    return _arequipaPlaces.where((place) {
      return place.name.toLowerCase().contains(queryLower) ||
          (place.description?.toLowerCase().contains(queryLower) ?? false) ||
          place.category.toLowerCase().contains(queryLower);
    }).toList();
  }

  /// Obtener lugares por categoría
  List<PlaceEntity> getPlacesByCategory(String category) {
    return _arequipaPlaces
        .where(
          (place) => place.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  /// Buscar lugar por ID
  PlaceEntity? getPlaceById(String id) {
    try {
      return _arequipaPlaces.firstWhere((place) => place.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener lugar más cercano a unas coordenadas
  PlaceEntity? getNearestPlace(
    LatLng coordinates, {
    double maxDistanceKm = 5.0,
  }) {
    PlaceEntity? nearestPlace;
    double minDistance = double.infinity;

    for (final place in _arequipaPlaces) {
      final distance = _calculateDistance(coordinates, place.coordinates);

      if (distance < minDistance && distance <= maxDistanceKm) {
        minDistance = distance;
        nearestPlace = place;
      }
    }

    return nearestPlace;
  }

  /// Calcular distancia entre dos puntos en kilómetros
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Radio de la Tierra en km

    double lat1Rad = point1.latitude * (pi / 180);
    double lat2Rad = point2.latitude * (pi / 180);
    double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    double deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    double a =
        pow(sin(deltaLatRad / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(deltaLngRad / 2), 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
