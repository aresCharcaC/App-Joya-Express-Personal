import 'package:joya_express/data/models/oferta_viaje_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/oferta_viaje_entity.dart';
import '../../domain/repositories/oferta_viaje_repository.dart';
import '../datasources/oferta_viaje_remote_datasource.dart';

class OfertaViajeRepositoryImpl implements OfertaViajeRepository {
  final OfertaViajeRemoteDataSource remoteDataSource;
  final SharedPreferences _prefs;
  static const String _cachePrefix = 'ofertas_cache_';

  OfertaViajeRepositoryImpl({
    required this.remoteDataSource,
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  @override
  Future<PaginatedResponse<OfertaViaje>> obtenerOfertas(
    String rideId, {
    int page = 1,
    int pageSize = 10,
    OfertaFilters? filters,
  }) async {
    try {
      // Intentar obtener datos del caché si es la primera página
      if (page == 1) {
        final cachedOfertas = await obtenerOfertasDeCache(rideId);
        if (cachedOfertas != null) {
          return _aplicarPaginacionYFiltros(cachedOfertas, page, pageSize, filters);
        }
      }

      // Si no hay caché o no es la primera página, obtener del servidor
      final response = await remoteDataSource.getOfertas(rideId);
      final ofertas = response.ofertas;

      // Guardar en caché si es la primera página
      if (page == 1) {
        await guardarOfertasEnCache(rideId, ofertas);
      }

      return _aplicarPaginacionYFiltros(ofertas, page, pageSize, filters);
    } catch (e) {
      throw Exception('Error en el repositorio: $e');
    }
  }

  @override
  Future<void> guardarOfertasEnCache(String rideId, List<OfertaViaje> ofertas) async {
    final key = _getCacheKey(rideId);
    final jsonOfertas = ofertas.map((o) => (o as OfertaViajeModel).toJson()).toList();
    await _prefs.setString(key, jsonEncode(jsonOfertas));
  }

  @override
  Future<List<OfertaViaje>?> obtenerOfertasDeCache(String rideId) async {
    final key = _getCacheKey(rideId);
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => OfertaViajeModel.fromJson(json)).toList();
  }

  @override
  Future<void> limpiarCacheOfertas(String rideId) async {
    final key = _getCacheKey(rideId);
    await _prefs.remove(key);
  }

  // Métodos auxiliares
  String _getCacheKey(String rideId) => '$_cachePrefix$rideId';

  PaginatedResponse<OfertaViaje> _aplicarPaginacionYFiltros(
    List<OfertaViaje> ofertas,
    int page,
    int pageSize,
    OfertaFilters? filters,
  ) {
    // Aplicar filtros si existen
    var ofertasFiltradas = ofertas;
    if (filters != null) {
      ofertasFiltradas = _aplicarFiltros(ofertas, filters);
    }

    // Aplicar ordenamiento si existe
    if (filters?.ordenarPor != null) {
      ofertasFiltradas = _ordenarOfertas(ofertasFiltradas, filters!.ordenarPor!, filters.ordenAscendente ?? true);
    }

    // Calcular índices para la paginación
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    final totalItems = ofertasFiltradas.length;
    final totalPages = (totalItems / pageSize).ceil();
    final hasNextPage = page < totalPages;
    final hasPreviousPage = page > 1;

    // Obtener la página actual
    final items = ofertasFiltradas.skip(startIndex).take(pageSize).toList();

    return PaginatedResponse(
      items: items,
      currentPage: page,
      totalPages: totalPages,
      totalItems: totalItems,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }

  List<OfertaViaje> _aplicarFiltros(List<OfertaViaje> ofertas, OfertaFilters filters) {
    return ofertas.where((oferta) {
      if (filters.precioMin != null && oferta.tarifaPropuesta < filters.precioMin!) {
        return false;
      }
      if (filters.precioMax != null && oferta.tarifaPropuesta > filters.precioMax!) {
        return false;
      }
      if (filters.distanciaMax != null) {
        final distancia = double.tryParse(oferta.distanciaConductor.replaceAll('km', '').trim()) ?? 0;
        if (distancia > filters.distanciaMax!) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<OfertaViaje> _ordenarOfertas(List<OfertaViaje> ofertas, String campo, bool ascendente) {
    switch (campo) {
      case 'precio':
        ofertas.sort((a, b) => ascendente
            ? a.tarifaPropuesta.compareTo(b.tarifaPropuesta)
            : b.tarifaPropuesta.compareTo(a.tarifaPropuesta));
        break;
      case 'distancia':
        ofertas.sort((a, b) {
          final distanciaA = double.tryParse(a.distanciaConductor.replaceAll('km', '').trim()) ?? 0;
          final distanciaB = double.tryParse(b.distanciaConductor.replaceAll('km', '').trim()) ?? 0;
          return ascendente ? distanciaA.compareTo(distanciaB) : distanciaB.compareTo(distanciaA);
        });
        break;
      case 'tiempo':
        ofertas.sort((a, b) {
          final tiempoA = _parsearTiempo(a.tiempoEstimado);
          final tiempoB = _parsearTiempo(b.tiempoEstimado);
          return ascendente ? tiempoA.compareTo(tiempoB) : tiempoB.compareTo(tiempoA);
        });
        break;
    }
    return ofertas;
  }

  int _parsearTiempo(String tiempoEstimado) {
    // Convertir "5 min" a 5, "1 hora" a 60, etc.
    if (tiempoEstimado.contains('hora')) {
      return int.parse(tiempoEstimado.replaceAll('hora', '').trim()) * 60;
    }
    return int.parse(tiempoEstimado.replaceAll('min', '').trim());
  }
} 