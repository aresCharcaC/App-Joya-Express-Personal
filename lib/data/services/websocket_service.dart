// lib/data/services/websocket_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../core/network/api_endpoints.dart';

typedef WebSocketMessageCallback = void Function(Map<String, dynamic> data);

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _conductorId;

  // Callbacks para diferentes eventos
  final Map<String, List<WebSocketMessageCallback>> _eventCallbacks = {};

  bool get isConnected => _isConnected;

  /// 🔌 Conectar conductor al WebSocket
  Future<bool> connectDriver(String conductorId, String token) async {
    try {
      _conductorId = conductorId;

      // ✅ URL DIRECTA SIN CONVERSIONES
      final wsUrl = ApiEndpoints.websocketUrl;

      print('🔌 Conectando WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['echo-protocol'],
      );

      // Esperar un poco antes de enviar auth
      await Future.delayed(const Duration(milliseconds: 500));

      // Autenticar conductor
      _send({
        'type': 'auth',
        'userType': 'conductor',
        'userId': conductorId,
        'token': token,
      });

      // Escuchar mensajes
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _isConnected = true;
      print('✅ WebSocket conectado como conductor: $conductorId');
      return true;
    } catch (e) {
      print('❌ Error conectando WebSocket: $e');
      _isConnected = false;
      return false;
    }
  }

  /// 📨 Enviar mensaje al servidor
  void _send(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      print('📤 WebSocket enviado: $jsonMessage');
    }
  }

  /// 📥 Manejar mensajes recibidos
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString()) as Map<String, dynamic>;
      final eventType = data['type'] ?? data['event'] ?? '';

      print('📥 WebSocket recibido: $eventType -> $data');

      // Ejecutar callbacks registrados
      if (_eventCallbacks.containsKey(eventType)) {
        for (final callback in _eventCallbacks[eventType]!) {
          callback(data);
        }
      }

      // Manejar eventos específicos
      switch (eventType) {
        case 'auth_success':
          print('✅ Autenticación WebSocket exitosa');
          break;
        case 'auth_error':
          print('❌ Error autenticación WebSocket: ${data['message']}');
          break;
        case 'ride:new':
          print('🆕 Nueva solicitud de viaje recibida');
          break;
        case 'ride:offer_accepted':
          print('✅ Oferta aceptada por pasajero');
          break;
        case 'ride:cancelled':
          print('❌ Viaje cancelado');
          break;
      }
    } catch (e) {
      print('❌ Error procesando mensaje WebSocket: $e');
    }
  }

  /// ❌ Manejar errores
  void _handleError(dynamic error) {
    print('❌ Error WebSocket: $error');
    _isConnected = false;
  }

  /// 💔 Manejar desconexión
  void _handleDisconnection() {
    print('💔 WebSocket desconectado');
    _isConnected = false;

    // Intentar reconectar después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isConnected && _conductorId != null) {
        print('🔄 Intentando reconectar WebSocket...');
        // TODO: Implementar lógica de reconexión con token válido
      }
    });
  }

  /// 🎯 Registrar callback para eventos específicos
  void onEvent(String eventType, WebSocketMessageCallback callback) {
    if (!_eventCallbacks.containsKey(eventType)) {
      _eventCallbacks[eventType] = [];
    }
    _eventCallbacks[eventType]!.add(callback);
    print('📝 Callback registrado para evento: $eventType');
  }

  /// 🗑️ Remover callback
  void removeEvent(String eventType, WebSocketMessageCallback callback) {
    if (_eventCallbacks.containsKey(eventType)) {
      _eventCallbacks[eventType]!.remove(callback);
    }
  }

  /// 📍 Enviar actualización de ubicación
  void sendLocationUpdate(double lat, double lng) {
    _send({
      'type': 'location:update',
      'conductorId': _conductorId,
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 💰 Enviar oferta de viaje
  void sendRideOffer({
    required String rideId,
    required double tarifa,
    required int tiempoEstimado,
    String? mensaje,
  }) {
    _send({
      'type': 'ride:offer',
      'rideId': rideId,
      'conductorId': _conductorId,
      'tarifa_propuesta': tarifa,
      'tiempo_estimado_llegada_minutos': tiempoEstimado,
      'mensaje': mensaje,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 🔄 Ping para mantener conexión
  void ping() {
    _send({'type': 'ping'});
  }

  /// 🔌 Desconectar
  void disconnect() {
    print('🔌 Desconectando WebSocket...');
    _isConnected = false;
    _conductorId = null;
    _eventCallbacks.clear();
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  /// 🧪 Método para debug - listar eventos registrados
  void debugEventCallbacks() {
    print('🧪 Eventos WebSocket registrados:');
    _eventCallbacks.forEach((event, callbacks) {
      print('   $event: ${callbacks.length} callbacks');
    });
  }
}
