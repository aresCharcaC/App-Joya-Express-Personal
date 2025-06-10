import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  String? _sessionCookies; // Para almacenar las cookies de sesión

  // GET Request con manejo de cookies
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      _handleCookies(response); // Procesar cookies de respuesta
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request con manejo de cookies
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      _handleCookies(response); // Procesar cookies de respuesta
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request con manejo de cookies
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.put(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      _handleCookies(response);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH Request con manejo de cookies
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.patch(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      _handleCookies(response);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Obtener headers con cookies de sesión
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(ApiEndpoints.jsonHeaders);
    
    // Agregar cookies de sesión si existen
    if (_sessionCookies != null) {
      headers['Cookie'] = _sessionCookies!;
    }
    
    return headers;
  }

  // Procesar cookies de respuesta del servidor
  void _handleCookies(http.Response response) {
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      // Parsear y almacenar cookies
      final cookieList = cookies.split(',');
      final sessionCookies = <String>[];
      
      for (final cookie in cookieList) {
        final cookieParts = cookie.trim().split(';');
        if (cookieParts.isNotEmpty) {
          final cookieNameValue = cookieParts[0];
          if (cookieNameValue.contains('accessToken') || 
              cookieNameValue.contains('refreshToken')) {
            sessionCookies.add(cookieNameValue);
          }
        }
      }
      
      if (sessionCookies.isNotEmpty) {
        _sessionCookies = sessionCookies.join('; ');
        _saveCookiesToStorage();
      }
    }
  }

  // Guardar cookies en almacenamiento local
  Future<void> _saveCookiesToStorage() async {
    if (_sessionCookies != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_cookies', _sessionCookies!);
    }
  }

  // Cargar cookies desde almacenamiento local
  Future<void> loadCookiesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionCookies = prefs.getString('session_cookies');
  }

  // Limpiar cookies de sesión
  Future<void> clearCookies() async {
    _sessionCookies = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookies');
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
  final statusCode = response.statusCode;

  if (statusCode >= 200 && statusCode < 300) {
    try {
      if (response.body.isEmpty) {
        // Si el cuerpo está vacío, devuelve un mapa vacío
        return {};
      }
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        throw ApiException(
          message: 'Respuesta inesperada del servidor (no es un objeto JSON)',
          statusCode: statusCode,
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'Error al procesar respuesta del servidor',
        statusCode: statusCode,
      );
    }
  } else {
    _handleHttpError(response);
  }

  throw ApiException(message: 'Respuesta inesperada del servidor');
}

  // Manejar errores HTTP específicos
  void _handleHttpError(http.Response response) {
    final statusCode = response.statusCode;
    String message = 'Error desconocido';
    
    try {
      final errorBody = json.decode(response.body);
      message = errorBody['message'] ?? message;
    } catch (e) {
      // Si no se puede parsear, usar mensaje por defecto
    }

    switch (statusCode) {
      case 400:
        throw ValidationException(message: message);
      case 401:
        // Token expirado, intentar refresh automáticamente
        throw AuthException(message: message);
      case 403:
        throw AuthException(message: 'Acceso denegado');
      case 404:
        throw ApiException(message: 'Recurso no encontrado', statusCode: 404);
      case 409:
        throw ValidationException(message: message);
      case 500:
        throw ServerException(message: 'Error interno del servidor', statusCode: 500);
      default:
        throw ApiException(message: message, statusCode: statusCode);
    }
  }

  // Manejar errores generales
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error is SocketException) {
      return NetworkException(message: 'Sin conexión a internet');
    } else if (error is HttpException) {
      return NetworkException(message: 'Error de red');
    } else {
      return ApiException(message: 'Error inesperado: ${error.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}