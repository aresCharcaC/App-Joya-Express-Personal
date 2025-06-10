import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:joya_express/core/network/api_client.dart';
import 'package:joya_express/data/datasources/auth_local_datasource.dart';
import 'package:joya_express/data/datasources/auth_remote_datasource.dart';
import 'package:joya_express/data/repositories_impl/auth_repository_impl.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_auth_viewmodel.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_home_viewmodel.dart';
import 'package:joya_express/presentation/modules/auth/Passenger/viewmodels/auth_viewmodel.dart';
import 'package:joya_express/presentation/modules/home/viewmodels/map_viewmodel.dart';
import 'package:joya_express/data/services/enhanced_vehicle_trip_service.dart';
import 'package:joya_express/data/services/dio_config.dart';
import 'package:joya_express/core/di/service_locator.dart';
import 'package:provider/provider.dart';
import 'presentation/modules/routes/app_routes.dart';

void main() async {
  // Asegurarse de que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();


  // ========== CONFIGURACIÓN DE DEBUG COMPLETO ==========
  // Capturar todos los errores de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    print('🔥 FLUTTER ERROR CAPTURADO:');
    print('Exception: ${details.exception}');
    print('Library: ${details.library}');
    print('Context: ${details.context}');
    print('Stack trace:');
    print(details.stack);
    print('==========================================');
    
    // En modo debug, también mostrar en pantalla roja
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // Capturar errores asincrónicos no manejados
  PlatformDispatcher.instance.onError = (error, stack) {
    print('🔥 ERROR ASÍNCRONO NO MANEJADO:');
    print('Error: $error');
    print('Stack trace:');
    print(stack);
    print('==========================================');
    return true;
  };
  // ===================================================

  // ========== INICIALIZAR DEPENDENCIAS INYECTADAS ==========
  print('🔧 Inicializando sistema de inyección de dependencias...');
  await initializeDependencies();
  diagnosticDependencies();
  print('✅ Sistema de inyección configurado');
  // =========================================================


  // ========== CONFIGURACIÓN MANUAL DE AUTH (LEGACY) ==========
  print('🚀 Iniciando Joya Express con autenticación REAL...');

  final apiClient = ApiClient();
  final remoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
  final localDataSource = AuthLocalDataSource();

  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  print('✅ Repositorio de autenticación configurado (manual)');
  // ===========================================================


  // ========== INICIALIZACIÓN DE SERVICIOS DE RUTA ==========
  try {
    await EnhancedVehicleTripService().initialize();
    print('✅ Servicios de ruta inicializados correctamente');
  } catch (e, stackTrace) {
    print('❌ Error inicializando servicios de ruta: $e');
    print('Stack trace: $stackTrace');
  }
  // =========================================================

  // ========== INICIALIZACIÓN DE AUTENTICACIÓN MANUAL ==========
  final authViewModel = AuthViewModel(authRepository: authRepository);
  
  try {
    await authViewModel.loadCurrentUser();
    print('✅ Usuario actual cargado');
  } catch (e, stackTrace) {
    print('⚠️ Error cargando usuario actual: $e');
    print('Stack trace: $stackTrace');
  }
  try {
    await authViewModel.initializeFromPersistedState();
    print('✅ Estado de autenticación inicializado');
  } catch (e, stackTrace) {
    print('⚠️ No hay estado previo de autenticación: $e');
    print('Stack trace: $stackTrace');
  }
  // ============================================================
  
  // ====================================================


  // ========== INICIAR APLICACIÓN ==========
  runApp(
    MultiProvider(
      providers: [

        // ========== PROVIDERS MANUALES (LEGACY) ==========
        // Provider de autenticación con repositorio real
        ChangeNotifierProvider.value(value: authViewModel), 
        
        // Provider del mapa
        ChangeNotifierProvider(create: (_) => MapViewModel()),
        
        // DriverHomeViewModel (manual)
        ChangeNotifierProvider(
          create: (_) => DriverHomeViewModel(),
        ),
        // =================================================

        // ========== PROVIDERS CON INYECCIÓN DE DEPENDENCIAS ==========
        // DriverAuthViewModel usando service locator
        ChangeNotifierProvider<DriverAuthViewModel>.value(
          value: sl<DriverAuthViewModel>(),
        ),
        // =============================================================
      ],
      child: const MyApp(),
    ),
  );

  print('🎉 Joya Express iniciado correctamente');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Obténemos los ViewModels del Provider
    final authViewModel = Provider.of<AuthViewModel>(context, listen: true);
    final driverAuthViewModel = Provider.of<DriverAuthViewModel>(context, listen: true);
    final driverHomeViewModel = Provider.of<DriverHomeViewModel>(context, listen: true);

    // Lógica para decidir la ruta inicial
    String initialRoute;
    if (driverAuthViewModel.isAuthenticated) {
      initialRoute = AppRoutes.driverHome;
    } else if (authViewModel.isAuthenticated) {
      initialRoute = AppRoutes.home;
    } else {
      initialRoute = AppRoutes.welcome;
    }

    return MaterialApp(
      title: 'Joya Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Configuración adicional del tema
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // initialRoute: initialRoute, // ← Ahora es dinámico
      //Probar la vista de mapas
      initialRoute: AppRoutes.welcome, 

      // Definimos las rutas de la aplicación
      routes: AppRoutes.routes,
    );
  }
}