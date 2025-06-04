import 'package:flutter/material.dart';
// ========== AUTENTICACIÓN REAL - VERSIÓN FINAL ==========
import 'package:joya_express/core/network/api_client.dart';
import 'package:joya_express/data/datasources/auth_local_datasource.dart';
import 'package:joya_express/data/datasources/auth_remote_datasource.dart';
import 'package:joya_express/data/repositories_impl/auth_repository_impl.dart';
import 'package:joya_express/presentation/modules/auth/viewmodels/auth_viewmodel.dart';
import 'package:joya_express/presentation/modules/home/viewmodels/map_viewmodel.dart';
import 'package:joya_express/data/services/enhanced_vehicle_trip_service.dart';
import 'package:provider/provider.dart';
import 'presentation/modules/routes/app_routes.dart';

void main() async {
  // Asegurarse de que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // ========== CONFIGURACIÓN REAL CON SERVIDOR ==========
  print('🚀 Iniciando Joya Express con autenticación REAL...');

  final apiClient = ApiClient();
  final remoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
  final localDataSource = AuthLocalDataSource();

  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  print('✅ Repositorio de autenticación configurado');
  // ===================================================

  // ========== INICIALIZACIÓN DE SERVICIOS DE RUTA ==========
  try {
    await EnhancedVehicleTripService().initialize();
    print('✅ Servicios de ruta inicializados correctamente');
  } catch (e) {
    print('❌ Error inicializando servicios de ruta: $e');
    // La app puede continuar, pero las rutas no funcionarán perfectamente
  }
  // =========================================================

  // ========== INICIALIZACIÓN DE AUTENTICACIÓN ==========
  final authViewModel = AuthViewModel(authRepository: authRepository);

  try {
    await authViewModel.initializeFromPersistedState();
    print('✅ Estado de autenticación inicializado');
  } catch (e) {
    print('⚠️ No hay estado previo de autenticación: $e');
  }
  // ====================================================

  // ========== INICIAR APLICACIÓN ==========
  runApp(
    MultiProvider(
      providers: [
        // Provider de autenticación con repositorio real
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        // Provider del mapa
        ChangeNotifierProvider(create: (_) => MapViewModel()),
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
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
