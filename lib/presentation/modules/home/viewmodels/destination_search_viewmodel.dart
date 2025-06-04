import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import '../../../../domain/entities/place_entity.dart';
import '../../../../data/services/places_service.dart';

/// ViewModel para manejo de búsqueda de destinos con historial
class DestinationSearchViewModel extends ChangeNotifier {
  final PlacesService _placesService = PlacesService();

  // Estado de búsqueda
  String _searchQuery = '';
  List<PlaceEntity> _searchResults = [];
  List<PlaceEntity> _recentDestinations = [];
  bool _isLoading = false;

  // Getters
  String get searchQuery => _searchQuery;
  List<PlaceEntity> get searchResults => _searchResults;
  List<PlaceEntity> get recentDestinations => _recentDestinations;
  bool get isLoading => _isLoading;
  bool get hasSearchQuery => _searchQuery.trim().isNotEmpty;
  bool get hasResults => _searchResults.isNotEmpty;

  /// Inicializar con destinos recientes
  void initialize() async {
    await _loadRecentDestinations();
    _searchResults = List.from(_recentDestinations);
    notifyListeners();
  }

  /// Buscar lugares por texto
  void searchPlaces(String query) {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    // Simular delay de búsqueda para mejor UX
    Future.delayed(const Duration(milliseconds: 300), () {
      if (query.trim().isEmpty) {
        // Si no hay búsqueda, mostrar destinos recientes
        _searchResults = List.from(_recentDestinations);
      } else {
        // Buscar en la base de lugares
        _searchResults = _placesService.searchPlaces(query);
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Limpiar búsqueda (volver a destinos recientes)
  void clearSearch() {
    _searchQuery = '';
    _searchResults = List.from(_recentDestinations);
    _isLoading = false;
    notifyListeners();
  }

  /// Agregar destino al historial reciente
  Future<void> addToRecentDestinations(PlaceEntity place) async {
    try {
      // Quitar si ya existe
      _recentDestinations.removeWhere((p) => p.id == place.id);

      // Agregar al principio
      _recentDestinations.insert(0, place);

      // Mantener solo los últimos 8
      if (_recentDestinations.length > 8) {
        _recentDestinations = _recentDestinations.take(8).toList();
      }

      // Guardar en SharedPreferences
      await _saveRecentDestinations();

      // Si no hay búsqueda activa, actualizar resultados
      if (!hasSearchQuery) {
        _searchResults = List.from(_recentDestinations);
        notifyListeners();
      }
    } catch (e) {
      print('Error guardando destino reciente: $e');
    }
  }

  /// Cargar destinos recientes desde SharedPreferences
  Future<void> _loadRecentDestinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recentJson = prefs.getString('recent_destinations');

      if (recentJson != null) {
        final List<dynamic> recentList = jsonDecode(recentJson);
        _recentDestinations =
            recentList.map((json) {
              return PlaceEntity(
                id: json['id'] ?? '',
                name: json['name'] ?? '',
                description: json['description'],
                coordinates: LatLng(
                  json['coordinates']['latitude'] ?? 0.0,
                  json['coordinates']['longitude'] ?? 0.0,
                ),
                category: json['category'] ?? 'Destino',
                isPopular: json['isPopular'] ?? false,
              );
            }).toList();
      } else {
        // Si no hay historial, usar lugares populares como fallback
        _recentDestinations =
            _placesService.getPopularPlaces().take(5).toList();
      }
    } catch (e) {
      print('Error cargando destinos recientes: $e');
      // Fallback a lugares populares
      _recentDestinations = _placesService.getPopularPlaces().take(5).toList();
    }
  }

  /// Guardar destinos recientes en SharedPreferences
  Future<void> _saveRecentDestinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> recentJson =
          _recentDestinations.map((place) {
            return {
              'id': place.id,
              'name': place.name,
              'description': place.description,
              'coordinates': {
                'latitude': place.coordinates.latitude,
                'longitude': place.coordinates.longitude,
              },
              'category': place.category,
              'isPopular': place.isPopular,
            };
          }).toList();

      await prefs.setString('recent_destinations', jsonEncode(recentJson));
    } catch (e) {
      print('Error guardando destinos recientes: $e');
    }
  }

  /// Obtener categorías (placeholder)
  void getPlacesByCategory(String category) {
    _isLoading = true;
    notifyListeners();

    _searchResults = _placesService.getPlacesByCategory(category);
    _isLoading = false;
    notifyListeners();
  }
}
