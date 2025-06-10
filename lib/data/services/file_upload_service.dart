import 'package:dio/dio.dart';
import 'package:joya_express/core/network/api_endpoints.dart';
import 'dart:io';

class FileUploadService {
  final Dio _dio;

  FileUploadService(this._dio);

  // Getter para acceso a la base URL desde el ViewModel
  String get baseUrl => _dio.options.baseUrl;

  Future<String> uploadFile(String filePath, String type) async {
    try {
      // Verificar que el archivo existe
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('El archivo no existe: $filePath');
      }

      print('Preparando archivo para upload: $filePath');
      print('Tamaño del archivo: ${await file.length()} bytes');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          // Opcional: especificar el nombre del archivo
          filename: filePath.split('/').last,
        ),
        'type': type,
      });

      print('FormData creado, enviando petición...');

      final response = await _dio.post(
        ApiEndpoints.driverUpload,
        data: formData,
        options: Options(
          // NO incluir Content-Type aquí, Dio lo maneja automáticamente para multipart
          headers: {
            'ngrok-skip-browser-warning': 'true',
            // Remover cualquier Content-Type para que Dio lo configure automáticamente
          },
          // Timeouts más largos para upload de archivos
          sendTimeout: Duration(seconds: 60),
          receiveTimeout: Duration(seconds: 60),
        ),
      );

      print('Respuesta recibida: ${response.statusCode}');
      print('Data de respuesta: ${response.data}');

      // Verificar que la respuesta sea exitosa
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map) {
          if (response.data['success'] == true && response.data['url'] != null) {
            return response.data['url'];
          } else {
            throw Exception('Respuesta del servidor sin URL: ${response.data}');
          }
        } else {
          throw Exception('Respuesta del servidor inválida: ${response.data}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (dioError) {
      print('DioException capturada:');
      print('Tipo: ${dioError.type}');
      print('Mensaje: ${dioError.message}');
      print('Response: ${dioError.response?.data}');
      print('Status Code: ${dioError.response?.statusCode}');
      
      // Manejo específico de errores de Dio
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('Timeout de conexión. Verifica tu conexión a internet.');
        case DioExceptionType.sendTimeout:
          throw Exception('Timeout enviando archivo. El archivo podría ser muy grande.');
        case DioExceptionType.receiveTimeout:
          throw Exception('Timeout recibiendo respuesta del servidor.');
        case DioExceptionType.badResponse:
          throw Exception('Error del servidor: ${dioError.response?.statusCode}');
        case DioExceptionType.cancel:
          throw Exception('Operación cancelada.');
        case DioExceptionType.unknown:
          throw Exception('Error de conexión. Verifica que el servidor esté disponible.');
        default:
          throw Exception('Error de red: ${dioError.message}');
      }
    } catch (e) {
      print('Error general en uploadFile: $e');
      throw Exception('Error al subir archivo: $e');
    }
  }
}