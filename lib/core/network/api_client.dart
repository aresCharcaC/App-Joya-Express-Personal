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
  
  // GET Request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
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

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Obtener headers con token si existe
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(ApiEndpoints.defaultHeaders);
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Manejar respuestas HTTP
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      try {
        return json.decode(response.body) as Map<String, dynamic>;
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