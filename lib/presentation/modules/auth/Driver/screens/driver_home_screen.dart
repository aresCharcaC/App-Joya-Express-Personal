import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/data/models/user/ride_request_model.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_home_viewmodel.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_auth_viewmodel.dart';
import 'package:joya_express/presentation/modules/auth/Driver/widgets/driver_drawer.dart';
import 'package:joya_express/presentation/modules/auth/Driver/widgets/driver_request_list.dart';
import 'package:joya_express/presentation/modules/auth/Driver/widgets/driver_status_toggle.dart';
import 'package:provider/provider.dart';
import '../screens/request_detail_screen.dart';
import '../../../../../data/models/ride_request_model.dart';

/// DriverHomeScreen
/// ----------------
/// Pantalla principal del conductor que muestra:
/// - Toggle de disponibilidad
/// - Lista de solicitudes de pasajeros cercanos
/// - Drawer con opciones del conductor
/// 
/// Refactorizada para eliminar redundancia y mejorar la separación de responsabilidades.
class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverHomeViewModel()..init()),
        // Se asume que DriverAuthViewModel ya está en el árbol de widgets superior
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Solicitudes', style: AppTextStyles.poppinsHeading2),
          actions: [
            // Indicador de estado de autenticación
            Consumer<DriverAuthViewModel>(
              builder: (context, authVm, _) {
                if (authVm.isAuthenticated) {
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        drawer: const DriverDrawer(),
        body: Consumer2<DriverHomeViewModel, DriverAuthViewModel>(
          builder: (context, homeVm, authVm, _) {
            // Verificar si está cargando
            if (authVm.isLoading) {
              return _buildLoadingState();
            }

            // Verificar autenticación
            if (!authVm.isAuthenticated || authVm.currentDriver == null) {
              _redirectToLogin(context);
              return _buildRedirectingState();
            }

            return Column(
              children: [
                // Toggle de disponibilidad
                DriverStatusToggle(
                  isAvailable: homeVm.disponible,
                  onStatusChanged: (isAvailable) async {
                    homeVm.setDisponible(isAvailable);
                    await authVm.setAvailability(isAvailable);
                  },
                ),

                // Lista de solicitudes
                Expanded(
                  child: DriverRequestList(
                    solicitudes: homeVm.solicitudes,
                    onRefresh: () async {
                      // TODO: Implementar refresh de solicitudes
                      // await homeVm.refreshSolicitudes();
                    },
                    onRequestTap: (request) {
                      // TODO: Implementar acción al tocar una solicitud
                      _showRequestDetails(context, request);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Construye el estado de carga
  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// Construye el estado de redirección
  Widget _buildRedirectingState() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Redirigiendo al login...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// Redirige al login si no está autenticado
  void _redirectToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/driver-login',
        (route) => false,
      );
    });
  }

  /// Muestra los detalles de una solicitud
  void _showRequestDetails(BuildContext context, dynamic request) {
    // Convertir a MockSolicitud si es necesario
    MockSolicitud mockSolicitud;

    if (request is MockSolicitud) {
      mockSolicitud = request;
    } else {
      // Para solicitudes reales del backend
      mockSolicitud = MockSolicitud(
        rideId: request['rideId'] ?? request['id'] ?? 'unknown',
        usuarioId: request['usuarioId'] ?? request['usuario_id'] ?? 'unknown',
        nombre: request['nombre'] ?? request['usuario_nombre'] ?? 'Usuario',
        foto:
            request['foto'] ??
            request['usuario_foto'] ??
            'https://randomuser.me/api/portraits/men/1.jpg',
        precio:
            (request['precio'] ?? request['tarifa_maxima'] ?? 0.0).toDouble(),
        direccion:
            request['direccion'] ??
            request['origen_direccion'] ??
            'Dirección no especificada',
        metodos: request['metodos'] ?? request['metodos_pago'] ?? ['Efectivo'],
        rating:
            (request['rating'] ?? request['usuario_rating'] ?? 4.5).toDouble(),
        votos: request['votos'] ?? request['usuario_votos'] ?? 0,
        origenLat:
            (request['origenLat'] ?? request['origen_lat'] ?? 0.0).toDouble(),
        origenLng:
            (request['origenLng'] ?? request['origen_lng'] ?? 0.0).toDouble(),
        destinoDireccion:
            request['destinoDireccion'] ??
            request['destino_direccion'] ??
            'Destino no especificado',
        destinoLat:
            (request['destinoLat'] ?? request['destino_lat'] ?? 0.0).toDouble(),
        destinoLng:
            (request['destinoLng'] ?? request['destino_lng'] ?? 0.0).toDouble(),
        estado: request['estado'] ?? 'pendiente',
        fechaSolicitud: request['fechaSolicitud'] ?? DateTime.now(),
        distanciaKm: request['distanciaKm']?.toDouble(),
        tiempoEstimadoMinutos: request['tiempoEstimadoMinutos'],
      );
    }

    // Navegar a la pantalla de detalle
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(solicitud: mockSolicitud),
      ),
    );
  }
}
