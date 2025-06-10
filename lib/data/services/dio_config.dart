// import 'package:dio/dio.dart';
// import 'package:joya_express/core/network/api_endpoints.dart';
// import 'package:joya_express/data/services/file_upload_service.dart';

// // DIAGNÓSTICO COMPLETO
// void diagnosticarConfiguracion() {
//   print('=== DIAGNÓSTICO COMPLETO ===');
  
//   // 1. Verificar ApiEndpoints
//   print('1. VERIFICANDO ApiEndpoints:');
//   print('   baseUrl: "${ApiEndpoints.baseUrl}"');
//   print('   Longitud: ${ApiEndpoints.baseUrl.length}');
//   print('   Es vacío: ${ApiEndpoints.baseUrl.isEmpty}');
//   print('   Caracteres: ${ApiEndpoints.baseUrl.codeUnits}');
  
//   // 2. Crear Dio temporal para testing
//   print('\n2. CREANDO DIO TEMPORAL:');
//   final testDio = Dio(BaseOptions(
//     baseUrl: ApiEndpoints.baseUrl,
//   ));
//   print('   Dio baseUrl: "${testDio.options.baseUrl}"');
//   print('   Longitud: ${testDio.options.baseUrl.length}');
  
//   // 3. Crear Dio con URL hardcodeada
//   print('\n3. CREANDO DIO CON URL DIRECTA:');
//   final directDio = Dio(BaseOptions(
//     baseUrl: 'https://7567-190-235-229-26.ngrok-free.app',
//   ));
//   print('   Dio baseUrl directo: "${directDio.options.baseUrl}"');
  
//   print('================================\n');
// }

// // OPCIÓN 1: Configuración con diagnósticos
// Dio createDioWithDiagnostics() {
//   print('=== CREANDO DIO PRINCIPAL ===');
  
//   final baseUrlToUse = ApiEndpoints.baseUrl.isEmpty 
//     ? 'https://7567-190-235-229-26.ngrok-free.app' 
//     : ApiEndpoints.baseUrl;
    
//   print('URL a usar: "$baseUrlToUse"');
  
//   final dioInstance = Dio(BaseOptions(
//     baseUrl: baseUrlToUse,
//     connectTimeout: Duration(seconds: 30),
//     receiveTimeout: Duration(seconds: 60),
//     sendTimeout: Duration(seconds: 60),
//   ));
  
//   print('Dio creado con baseUrl: "${dioInstance.options.baseUrl}"');
//   print('===============================\n');
  
//   return dioInstance;
// }

// // OPCIÓN 2: Configuración directa (fallback)
// final dioDirect = Dio(BaseOptions(
//   baseUrl: 'https://7567-190-235-229-26.ngrok-free.app',
//   connectTimeout: Duration(seconds: 30),
//   receiveTimeout: Duration(seconds: 60),
//   sendTimeout: Duration(seconds: 60),
// ));

// // Usar la función de diagnóstico
// final dio = createDioWithDiagnostics();
// final fileUploadService = FileUploadService(dio);

// // Función para llamar en main() o donde inicialices la app
// void inicializarDiagnosticos() {
//   diagnosticarConfiguracion();
// }