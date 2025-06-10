// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:joya_express/core/network/api_client.dart';
import 'package:joya_express/core/network/api_endpoints.dart';
import 'package:joya_express/data/datasources/driver_local_datasource.dart';
import 'package:joya_express/data/datasources/driver_remote_datasource.dart';
import 'package:joya_express/data/repositories_impl/driver_repository_impl.dart';
import 'package:joya_express/data/services/file_upload_service.dart';
import 'package:joya_express/domain/repositories/driver_repository.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_auth_viewmodel.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  print('=== INICIALIZANDO DEPENDENCIAS ===');

  // 1. Configurar Dio
  _setupDio();

  // 2. Configurar servicios
  _setupServices();

  // 3. Configurar repositorios
  _setupRepositories();

  // 4. Configurar ViewModels
  _setupViewModels();

  print('=== DEPENDENCIAS INICIALIZADAS ===');
}

void _setupDio() {
  print('Configurando Dio...');

  // Diagnóstico de la URL
  final baseUrl = ApiEndpoints.baseUrl;
  print('Base URL desde ApiEndpoints: "$baseUrl"');
  print('Longitud de URL: ${baseUrl.length}');
  print('¿URL vacía?: ${baseUrl.isEmpty}');

  // Crear instancia de Dio con configuración completa
  final dio = Dio(
    BaseOptions(
      baseUrl:
          baseUrl.isEmpty
              ? 'https://7567-190-235-229-26.ngrok-free.app'
              : baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: ApiEndpoints.baseHeaders,
    ),
  );

  // Agregar interceptor para debugging
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
      logPrint: (object) => print('DIO: $object'),
    ),
  );

  print('Dio configurado con URL: "${dio.options.baseUrl}"');

  // Registrar como singleton
  sl.registerSingleton<Dio>(dio);
}

void _setupServices() {
  print('Configurando servicios...');
  // Registrar ApiClient primero
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  // Luego las data sources
  sl.registerLazySingleton<DriverRemoteDataSource>(
    () => DriverRemoteDataSource(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<DriverLocalDataSource>(
    () => DriverLocalDataSource(),
  );
  // FileUploadService
  sl.registerLazySingleton<FileUploadService>(() {
    final service = FileUploadService(sl<Dio>());
    print(
      'FileUploadService creado con Dio base URL: ${sl<Dio>().options.baseUrl}',
    );
    return service;
  });
}

void _setupRepositories() {
  print('Configurando repositorios...');

  // DriverRepository
  sl.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(
      sl<Dio>(),
      remote: sl<DriverRemoteDataSource>(),
      local: sl<DriverLocalDataSource>(),
      fileUploadService: sl<FileUploadService>(),
    ),
  );
}

void _setupViewModels() {
  print('Configurando ViewModels...');

  // DriverAuthViewModel
  sl.registerFactory<DriverAuthViewModel>(
    () => DriverAuthViewModel(sl<DriverRepository>(), sl<FileUploadService>()),
  );
}

// Función para hacer diagnóstico completo
void diagnosticDependencies() {
  print('\n=== DIAGNÓSTICO DE DEPENDENCIAS ===');

  try {
    final dio = sl<Dio>();
    print('✅ Dio registrado correctamente');
    print('   Base URL: "${dio.options.baseUrl}"');
    print('   Headers: ${dio.options.headers}');

    final fileService = sl<FileUploadService>();
    print('✅ FileUploadService registrado correctamente');

    final repository = sl<DriverRepository>();
    print('✅ DriverRepository registrado correctamente');

    final viewModel = sl<DriverAuthViewModel>();
    print('✅ DriverAuthViewModel registrado correctamente');
  } catch (e) {
    print('❌ Error en diagnóstico: $e');
  }

  print('=== FIN DIAGNÓSTICO ===\n');
}
