// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:joya_express/core/config/app_config.dart';
import 'package:joya_express/core/network/api_client.dart';
import 'package:joya_express/core/network/api_endpoints.dart';
import 'package:joya_express/data/datasources/driver_local_datasource.dart';
import 'package:joya_express/data/datasources/driver_remote_datasource.dart';
import 'package:joya_express/data/datasources/oferta_viaje_remote_datasource.dart';
import 'package:joya_express/data/repositories_impl/driver_repository_impl.dart';
import 'package:joya_express/data/services/file_upload_service.dart';
import 'package:joya_express/domain/repositories/driver_repository.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_auth_viewmodel.dart';
import 'package:joya_express/data/datasources/ride_remote_datasource.dart';
import 'package:joya_express/data/repositories_impl/ride_repository_impl.dart';
import 'package:joya_express/domain/repositories/ride_repository.dart';
import 'package:joya_express/domain/usecases/create_ride_request_usecase.dart';
import 'package:joya_express/presentation/providers/ride_provider.dart';
import 'package:joya_express/data/repositories/oferta_viaje_repository_impl.dart';
import 'package:joya_express/domain/repositories/oferta_viaje_repository.dart';
import 'package:joya_express/domain/usecases/obtener_ofertas_usecase.dart';
import 'package:joya_express/presentation/modules/home/viewmodels/ofertas_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**
 * Inyectar dependencias usando GetIt()
 */
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
  
  // Usar la configuración desde AppConfig
  final baseUrl = AppConfig.baseUrl;
  print('Base URL desde AppConfig: "$baseUrl"');
  
  // Crear instancia de Dio con configuración completa
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    sendTimeout: AppConfig.sendTimeout,
    headers: ApiEndpoints.baseHeaders,
  ));
  
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

  // Registrar RideRemoteDataSource
  sl.registerLazySingleton<RideRemoteDataSource>(
    () => RideRemoteDataSource(apiClient: sl<ApiClient>()),
  );
  // Registrar OfertaViajeRemoteDataSource
  sl.registerLazySingleton<OfertaViajeRemoteDataSource>(
    () => OfertaViajeRemoteDataSourceImpl(
      sl<ApiClient>(),
    ),
  );
  
  // FileUploadService
  sl.registerLazySingleton<FileUploadService>(() {
    final service = FileUploadService(sl<Dio>());
    print('FileUploadService creado con Dio base URL: ${sl<Dio>().options.baseUrl}');
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

  // RideRepository
  sl.registerLazySingleton<RideRepository>(
    () => RideRepositoryImpl(
      remoteDataSource: sl<RideRemoteDataSource>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<OfertaViajeRepository>(
    () => OfertaViajeRepositoryImpl(
      remoteDataSource: sl<OfertaViajeRemoteDataSource>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
}

void _setupViewModels() {
  print('Configurando ViewModels...');

  // DriverAuthViewModel
  sl.registerFactory<DriverAuthViewModel>(
    () => DriverAuthViewModel(sl<DriverRepository>(), sl<FileUploadService>()),
  );

  // Registrar el caso de uso de Ride
  sl.registerLazySingleton<CreateRideRequestUseCase>(
    () => CreateRideRequestUseCase(sl<RideRepository>()),
  );

  // Registrar el provider de Ride
  sl.registerFactory<RideProvider>(
    () => RideProvider(sl<CreateRideRequestUseCase>()),
  );

  
  // UseCases
  sl.registerLazySingleton<ObtenerOfertasUseCase>(
    () => ObtenerOfertasUseCase(
      repository: sl<OfertaViajeRepository>(),
    ),
  );
  // ViewModels
  sl.registerFactory<OfertasViewModel>(
    () => OfertasViewModel(
      obtenerOfertasUseCase: sl<ObtenerOfertasUseCase>(),
    ),
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
    
    final driverRepository = sl<DriverRepository>();
    print('✅ DriverRepository registrado correctamente');
    
    final driverViewModel = sl<DriverAuthViewModel>();
    print('✅ DriverAuthViewModel registrado correctamente');

    // Diagnóstico del módulo de viajes
    final rideDataSource = sl<RideRemoteDataSource>();
    print('✅ RideRemoteDataSource registrado correctamente');
    
    final rideRepository = sl<RideRepository>();
    print('✅ RideRepository registrado correctamente');
    
    final rideUseCase = sl<CreateRideRequestUseCase>();
    print('✅ CreateRideRequestUseCase registrado correctamente');
    
    final rideProvider = sl<RideProvider>();
    print('✅ RideProvider registrado correctamente');
    
    // Ofertas de Viaje
    final ofertaViajeDataSource = sl<OfertaViajeRemoteDataSource>();
    print('✅ OfertaViajeRemoteDataSource registrado correctamente');
    
    final ofertaViajeRepository = sl<OfertaViajeRepository>();
    print('✅ OfertaViajeRepository registrado correctamente');
    
    final obtenerOfertasUseCase = sl<ObtenerOfertasUseCase>();
    print('✅ ObtenerOfertasUseCase registrado correctamente');
    
    final ofertasViewModel = sl<OfertasViewModel>();
    print('✅ OfertasViewModel registrado correctamente');
    
  } catch (e) {
    print('❌ Error en diagnóstico: $e');
  }

  print('=== FIN DIAGNÓSTICO ===\n');
}

void _setupCore() {
  print('Configurando servicios core...');
  
  // SharedPreferences
  sl.registerLazySingleton<SharedPreferences>(
    () => throw UnimplementedError('SharedPreferences debe ser inicializado'),
  );

  // ... existing code ...
}
