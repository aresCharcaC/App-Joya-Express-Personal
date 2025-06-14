import 'package:flutter/material.dart';
import '../../../../domain/entities/oferta_viaje_entity.dart';
import '../../../../domain/usecases/obtener_ofertas_usecase.dart';

class OfertasViewModel extends ChangeNotifier {
  final ObtenerOfertasUseCase _obtenerOfertasUseCase;

  OfertasViewModel({
    required ObtenerOfertasUseCase obtenerOfertasUseCase,
  }) : _obtenerOfertasUseCase = obtenerOfertasUseCase;

  // Estado
  bool _isLoading = false;
  String? _error;
  List<OfertaViaje> _ofertas = [];
  String? _selectedOfertaId;
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  OfertaFilters _filters = OfertaFilters();
  bool _isLoadingMore = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<OfertaViaje> get ofertas => _ofertas;
  String? get selectedOfertaId => _selectedOfertaId;
  bool get hasOfertas => _ofertas.isNotEmpty;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  bool get isLoadingMore => _isLoadingMore;
  OfertaFilters get filters => _filters;

  // Métodos
  Future<void> cargarOfertas(String rideId, {bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _ofertas = [];
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _obtenerOfertasUseCase.execute(
        rideId,
        page: _currentPage,
        filters: _filters,
      );

      if (refresh) {
        _ofertas = response.items;
      } else {
        _ofertas.addAll(response.items);
      }

      _hasNextPage = response.hasNextPage;
      _hasPreviousPage = response.hasPreviousPage;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarMasOfertas(String rideId) async {
    if (_isLoadingMore || !_hasNextPage) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      _currentPage++;
      await cargarOfertas(rideId);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void aplicarFiltros(OfertaFilters nuevosFiltros) {
    _filters = nuevosFiltros;
    _currentPage = 1;
    _ofertas = [];
    notifyListeners();
  }

  void ordenarPor(String campo, {bool ascendente = true}) {
    _filters = OfertaFilters(
      ordenarPor: campo,
      ordenAscendente: ascendente,
    );
    _currentPage = 1;
    _ofertas = [];
    notifyListeners();
  }

  void seleccionarOferta(String ofertaId) {
    _selectedOfertaId = ofertaId;
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void limpiarOfertas() {
    _ofertas = [];
    _selectedOfertaId = null;
    _currentPage = 1;
    _hasNextPage = false;
    _hasPreviousPage = false;
    notifyListeners();
  }
} 