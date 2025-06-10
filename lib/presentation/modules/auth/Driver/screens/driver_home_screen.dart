import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_home_viewmodel.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_auth_viewmodel.dart';
import 'package:joya_express/presentation/modules/auth/Driver/widgets/driver_drawer.dart';
import 'package:joya_express/presentation/modules/auth/Driver/widgets/driver_request_list.dart';
import 'package:joya_express/presentation/modules/auth/Driver/widgets/driver_status_toggle.dart';
import 'package:provider/provider.dart';

/**
 * DriverHomeScreen
 * ----------------
 * Pantalla principal del conductor que muestra:
 * - Toggle de disponibilidad
 * - Lista de solicitudes de pasajeros cercanos
 * - Drawer con opciones del conductor
 * 
 * Refactorizada para eliminar redundancia y mejorar la separación de responsabilidades.
 */
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
          title: Text('Principal', style: AppTextStyles.poppinsHeading2),
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
                
                // Título de solicitudes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Solicitudes de pasajeros cercanos',
                      style: AppTextStyles.poppinsHeading3,
                    ),
                  ),
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
            Text(
              'Cargando...',
              style: TextStyle(fontSize: 16),
            ),
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
            Icon(
              Icons.logout,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Redirigiendo al login...',
              style: TextStyle(fontSize: 16),
            ),
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
        (route) => false
      );
    });
  }

  /// Muestra los detalles de una solicitud
  void _showRequestDetails(BuildContext context, dynamic request) {
    // TODO: Implementar modal o navegación a detalles de solicitud
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detalles de la solicitud',
              style: AppTextStyles.poppinsHeading2,
            ),
            const SizedBox(height: 16),
            Text('Nombre: ${request.nombre ?? 'N/A'}'),
            Text('Precio: S/ ${request.precio?.toStringAsFixed(2) ?? '0.00'}'),
            Text('Dirección: ${request.direccion ?? 'N/A'}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implementar aceptar solicitud
                      Navigator.pop(context);
                    },
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}