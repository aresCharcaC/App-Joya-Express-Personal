import 'package:flutter/foundation.dart';
import 'package:joya_express/domain/entities/ride_request_entity.dart';
import 'package:joya_express/domain/usecases/create_ride_request_usecase.dart';
import 'dart:developer' as developer;
// Provider que maneja el estado de la UI para solicitar viajes
// Extiende ChangeNotifier para notificar cambios a los widgets que lo escuchan

class RideProvider extends ChangeNotifier {
  // Caso de uso que maneja la lógica de creación de viajes
  final CreateRideRequestUseCase _createRideRequestUseCase;
  
  RideRequest? _currentRide;
  List<RideRequest> _activeRides = [];
  bool _isLoading = false;
  String? _error;
  // Constructor que recibe el caso de uso por inyección de dependencia
  RideProvider(this._createRideRequestUseCase);

  // Getters
  RideRequest? get currentRide => _currentRide;
  List<RideRequest> get activeRides => _activeRides;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Método para crear una nueva solicitud de viaje
  Future<bool> createRideRequest(RideRequest request) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('🚗 Iniciando creación de solicitud de viaje...', 
          name: 'RideProvider');

      _currentRide = await _createRideRequestUseCase(request);
      _activeRides.add(_currentRide!);

      developer.log('✅ Solicitud de viaje creada exitosamente', 
          name: 'RideProvider');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      developer.log('❌ Error al crear solicitud de viaje: $e', 
          name: 'RideProvider');
      notifyListeners();
      return false;
    }
  }

  // Método para limpiar el estado actual
  void clearState() {
    _currentRide = null;
    _error = null;
    notifyListeners();
  }

  // Método para limpiar el error
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 