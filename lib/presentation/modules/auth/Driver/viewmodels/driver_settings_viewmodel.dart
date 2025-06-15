import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// DriverSettingsViewModel
/// ----------------------
/// Maneja la configuración local del conductor usando SharedPreferences
/// - Radio de búsqueda de solicitudes
/// - Ordenamiento de solicitudes
/// - Filtros locales
class DriverSettingsViewModel extends ChangeNotifier {
  // Configuración por defecto
  double _searchRadiusKm = 1.0; // 1 km por defecto
  SortOption _sortOption = SortOption.distance;
  bool _filterByMinPrice = false;
  double _minPrice = 5.0;
  bool _soundNotifications = true;

  bool _isLoading = false;
  bool _hasChanges = false;

  // Getters
  double get searchRadiusKm => _searchRadiusKm;
  SortOption get sortOption => _sortOption;
  bool get filterByMinPrice => _filterByMinPrice;
  double get minPrice => _minPrice;
  bool get soundNotifications => _soundNotifications;
  bool get isLoading => _isLoading;
  bool get hasChanges => _hasChanges;

  // Keys para SharedPreferences
  static const String _keySearchRadius = 'driver_search_radius';
  static const String _keySortOption = 'driver_sort_option';
  static const String _keyFilterByMinPrice = 'driver_filter_min_price';
  static const String _keyMinPrice = 'driver_min_price_value';
  static const String _keySoundNotifications = 'driver_sound_notifications';

  /// Inicializar y cargar configuración guardada
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadSettings();
    } catch (e) {
      print('❌ Error cargando configuración: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cargar configuración desde SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _searchRadiusKm = prefs.getDouble(_keySearchRadius) ?? 1.0;

    final sortIndex = prefs.getInt(_keySortOption) ?? 0;
    _sortOption = SortOption.values[sortIndex];

    _filterByMinPrice = prefs.getBool(_keyFilterByMinPrice) ?? false;
    _minPrice = prefs.getDouble(_keyMinPrice) ?? 5.0;
    _soundNotifications = prefs.getBool(_keySoundNotifications) ?? true;

    print(
      '✅ Configuración cargada: Radio=${_searchRadiusKm}km, Sort=${_sortOption.name}',
    );
  }

  /// Guardar configuración en SharedPreferences
  Future<bool> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setDouble(_keySearchRadius, _searchRadiusKm);
      await prefs.setInt(_keySortOption, _sortOption.index);
      await prefs.setBool(_keyFilterByMinPrice, _filterByMinPrice);
      await prefs.setDouble(_keyMinPrice, _minPrice);
      await prefs.setBool(_keySoundNotifications, _soundNotifications);

      _hasChanges = false;
      notifyListeners();

      print('✅ Configuración guardada correctamente');
      return true;
    } catch (e) {
      print('❌ Error guardando configuración: $e');
      return false;
    }
  }

  /// Setters con notificación de cambios
  void setSearchRadius(double radius) {
    if (_searchRadiusKm != radius) {
      _searchRadiusKm = radius;
      _hasChanges = true;
      notifyListeners();
    }
  }

  void setSortOption(SortOption? option) {
    if (option != null && _sortOption != option) {
      _sortOption = option;
      _hasChanges = true;
      notifyListeners();
    }
  }

  void setFilterByMinPrice(bool filter) {
    if (_filterByMinPrice != filter) {
      _filterByMinPrice = filter;
      _hasChanges = true;
      notifyListeners();
    }
  }

  void setMinPrice(double price) {
    if (_minPrice != price) {
      _minPrice = price;
      _hasChanges = true;
      notifyListeners();
    }
  }

  void setSoundNotifications(bool enabled) {
    if (_soundNotifications != enabled) {
      _soundNotifications = enabled;
      _hasChanges = true;
      notifyListeners();
    }
  }

  /// Resetear a valores por defecto
  void resetToDefaults() {
    _searchRadiusKm = 1.0;
    _sortOption = SortOption.distance;
    _filterByMinPrice = false;
    _minPrice = 5.0;
    _soundNotifications = true;
    _hasChanges = true;
    notifyListeners();
  }

  /// Obtener radio en metros (para cálculos)
  double get searchRadiusMeters => _searchRadiusKm * 1000;

  /// Aplicar filtros a una lista de solicitudes
  List<T> applySorting<T>(
    List<T> solicitudes, {
    required double Function(T) getDistance,
    required double Function(T) getPrice,
    required DateTime Function(T) getTime,
  }) {
    // Crear copia para no modificar la original
    final List<T> sortedList = List.from(solicitudes);

    // Aplicar ordenamiento según configuración
    switch (_sortOption) {
      case SortOption.distance:
        sortedList.sort((a, b) => getDistance(a).compareTo(getDistance(b)));
        break;
      case SortOption.price:
        sortedList.sort(
          (a, b) => getPrice(b).compareTo(getPrice(a)),
        ); // Mayor precio primero
        break;
      case SortOption.time:
        sortedList.sort(
          (a, b) => getTime(b).compareTo(getTime(a)),
        ); // Más reciente primero
        break;
    }

    return sortedList;
  }

  /// Filtrar solicitudes según configuración
  List<T> applyFilters<T>(
    List<T> solicitudes, {
    required double Function(T) getPrice,
  }) {
    if (!_filterByMinPrice) return solicitudes;

    return solicitudes.where((solicitud) {
      return getPrice(solicitud) >= _minPrice;
    }).toList();
  }
}

// Enum para opciones de ordenamiento
enum SortOption {
  distance, // Por cercanía
  price, // Por precio
  time, // Por tiempo de solicitud
}
