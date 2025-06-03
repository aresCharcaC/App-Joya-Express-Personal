import 'package:flutter/material.dart';
import 'package:joya_express/data/datasources/auth_local_datasource.dart';
import 'package:joya_express/data/repositories_impl/auth_repository_mock_impl.dart'; // ← TEMPORAL
import 'package:joya_express/presentation/modules/auth/viewmodels/auth_viewmodel.dart';
// NUEVA IMPORTACIÓN
import 'package:joya_express/presentation/modules/map/viewmodels/map_viewmodel.dart';
import 'package:provider/provider.dart';
import 'presentation/modules/routes/app_routes.dart';

void main() async {
  // Asegurarse de que los bindings de Flutter estén inicializados antes de usar Provider
  WidgetsFlutterBinding.ensureInitialized();

  // ========== CONFIGURACIÓN TEMPORAL MOCK ==========
  final localDataSource = AuthLocalDataSource();
  final authRepository = AuthRepositoryMockImpl(
    localDataSource: localDataSource,
  );
  // ===============================================

  final authViewModel = AuthViewModel(authRepository: authRepository);
  await authViewModel.initializeFromPersistedState();

  // Iniciar la aplicación con múltiples ViewModels
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        // NUEVO PROVIDER PARA EL MAPA
        ChangeNotifierProvider(create: (_) => MapViewModel()),
      ],
      child: const MyApp(),
    ),
  );
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
      ),
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
/*

import 'package:flutter/material.dart';
import 'package:joya_express/core/network/api_client.dart';
import 'package:joya_express/data/datasources/auth_local_datasource.dart';
import 'package:joya_express/data/datasources/auth_remote_datasource.dart';
import 'package:joya_express/data/repositories_impl/auth_repository_impl.dart';
import 'package:joya_express/presentation/modules/auth/screens/welcome_screen.dart';
import 'package:joya_express/presentation/modules/auth/viewmodels/auth_viewmodel.dart';
// NUEVA IMPORTACIÓN
import 'package:joya_express/presentation/modules/map/viewmodels/map_viewmodel.dart';
import 'package:provider/provider.dart';
import 'presentation/modules/routes/app_routes.dart';

void main() async {
  // Asegurarse de que los bindings de Flutter estén inicializados antes de usar Provider
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final remoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
  final localDataSource = AuthLocalDataSource();
  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
  final authViewModel = AuthViewModel(authRepository: authRepository);
  await authViewModel.initializeFromPersistedState();

  // Iniciar la aplicación con múltiples ViewModels
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        // NUEVO PROVIDER PARA EL MAPA
        ChangeNotifierProvider(create: (_) => MapViewModel()),
      ],
      child: const MyApp(),
    ),
  );
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
      ),
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
*/