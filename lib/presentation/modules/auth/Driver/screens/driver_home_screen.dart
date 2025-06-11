import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_home_viewmodel.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_auth_viewmodel.dart';
import 'package:joya_express/presentation/modules/auth/Driver/widgets/driver_drawer.dart';
import 'package:joya_express/presentation/modules/auth/Driver/widgets/driver_request_list.dart';
import 'package:joya_express/presentation/modules/auth/Driver/widgets/driver_status_toggle.dart';
import 'package:joya_express/presentation/modules/auth/Driver/widgets/request_details_modal.dart';
import 'package:provider/provider.dart';

/**
 * DriverHomeScreen ACTUALIZADA
 * ----------------
 * Pantalla principal del conductor con:
 * - Integración con backend real
 * - WebSocket para tiempo real
 * - GPS automático
 * - Modal de detalles optimizado
 */
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inicializar después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWithAuth();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Inicializar con datos de autenticación
  void _initializeWithAuth() {
    final authVm = Provider.of<DriverAuthViewModel>(context, listen: false);
    final homeVm = Provider.of<DriverHomeViewModel>(context, listen: false);

    if (authVm.isAuthenticated && authVm.currentDriver != null) {
      final driver = authVm.currentDriver!;

      // Inicializar con ID y token reales
      homeVm.init(
        conductorId: driver.id,
        token: 'dummy_token', // TODO: Obtener token real del authVm
      );

      print('✅ Home inicializado para conductor: ${driver.nombreCompleto}');
    } else {
      print('⚠️ No hay conductor autenticado');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final homeVm = Provider.of<DriverHomeViewModel>(context, listen: false);

    switch (state) {
      case AppLifecycleState.paused:
        // App en background - mantener ubicación pero reducir frecuencia
        print('📱 App en background');
        break;
      case AppLifecycleState.resumed:
        // App activa - reanudar servicios completos
        print('📱 App activa - refrescando solicitudes');
        homeVm.refreshSolicitudes();
        break;
      case AppLifecycleState.detached:
        // App cerrada - limpiar recursos
        print('📱 App cerrada');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DriverHomeViewModel())],
      child: Scaffold(
        appBar: _buildAppBar(),
        drawer: const DriverDrawer(),
        body: Consumer2<DriverHomeViewModel, DriverAuthViewModel>(
          builder: (context, homeVm, authVm, _) {
            // Estados de carga y error
            if (authVm.isLoading) {
              return _buildLoadingState();
            }

            if (!authVm.isAuthenticated || authVm.currentDriver == null) {
              _redirectToLogin(context);
              return _buildRedirectingState();
            }

            if (homeVm.error != null) {
              return _buildErrorState(homeVm.error!, () {
                homeVm.refreshSolicitudes();
              });
            }

            return Column(
              children: [
                // Toggle de disponibilidad MÁS COMPACTO
                _buildCompactStatusToggle(homeVm, authVm),

                // ✅ QUITAR BARRA AZUL DE UBICACIÓN (comentado)
                // _buildLocationInfo(homeVm),

                // Título de solicitudes
                _buildSectionTitle(homeVm),

                // Lista de solicitudes optimizada
                Expanded(
                  child: DriverRequestList(
                    solicitudes: homeVm.solicitudes,
                    onRefresh: homeVm.refreshSolicitudes,
                    onRequestTap:
                        (request) =>
                            _showRequestDetails(context, request, homeVm),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Principal',
        style: AppTextStyles.poppinsHeading2.copyWith(fontSize: 18),
      ),
      elevation: 0,
      actions: [
        // Indicador de conexión WebSocket
        Consumer<DriverHomeViewModel>(
          builder: (context, homeVm, _) {
            return Container(
              margin: const EdgeInsets.only(right: 16),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: homeVm.disponible ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Indicador de ubicación GPS
                    Icon(
                      homeVm.currentPosition != null
                          ? Icons.gps_fixed
                          : Icons.gps_not_fixed,
                      size: 16,
                      color:
                          homeVm.currentPosition != null
                              ? Colors.green
                              : Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompactStatusToggle(
    DriverHomeViewModel homeVm,
    DriverAuthViewModel authVm,
  ) {
    return Container(
      margin: const EdgeInsets.all(12), // ✅ Restaurado bonito
      child: DriverStatusToggle(
        isAvailable: homeVm.disponible,
        onStatusChanged: (isAvailable) async {
          homeVm.setDisponible(isAvailable);
          await authVm.setAvailability(isAvailable);
        },
      ),
    );
  }

  Widget _buildLocationInfo(DriverHomeViewModel homeVm) {
    if (homeVm.currentPosition == null && !homeVm.disponible) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              homeVm.currentPosition != null
                  ? 'Ubicación: ${homeVm.currentPosition!.latitude.toStringAsFixed(4)}, ${homeVm.currentPosition!.longitude.toStringAsFixed(4)}'
                  : 'Obteniendo ubicación...',
              style: AppTextStyles.interBodySmall.copyWith(
                color: Colors.blue[700],
                fontSize: 11,
              ),
            ),
          ),
          if (homeVm.isLoadingSolicitudes)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(DriverHomeViewModel homeVm) {
    final totalSolicitudes = homeVm.solicitudes.length;
    final solicitudesOriginales =
        homeVm.todasLasSolicitudes.length; // ✅ Usar getter público

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4), // ✅ Reducido espaciado
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            homeVm.disponible
                ? 'Solicitudes cercanas'
                : 'Todas las solicitudes',
            style: AppTextStyles.poppinsHeading3.copyWith(
              fontSize: 15,
            ), // ✅ Reducido
          ),
          if (totalSolicitudes > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    homeVm.disponible
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                homeVm.disponible && solicitudesOriginales > totalSolicitudes
                    ? '$totalSolicitudes de $solicitudesOriginales'
                    : '$totalSolicitudes',
                style: AppTextStyles.interBodySmall.copyWith(
                  fontSize: 11,
                  color:
                      homeVm.disponible ? Colors.green[700] : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Mostrar modal de detalles de solicitud
  void _showRequestDetails(
    BuildContext context,
    dynamic request,
    DriverHomeViewModel homeVm,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => RequestDetailsModal(
            request: request,
            onMakeOffer: (rideId, tarifa, tiempo, mensaje) async {
              print('💰 Haciendo oferta: $rideId - S/$tarifa - ${tiempo}min');

              final success = await homeVm.makeOffer(
                rideId: rideId,
                tarifa: tarifa,
                tiempoEstimado: tiempo,
                mensaje: mensaje,
              );

              if (success) {
                // Remover de la lista local (ya no disponible)
                homeVm.solicitudes.removeWhere((s) => s.rideId == rideId);
                homeVm.notifyListeners();
              }

              return success;
            },
            onReject: (rideId) async {
              print('❌ Rechazando solicitud: $rideId');

              final success = await homeVm.rejectRequest(rideId);
              return success;
            },
          ),
    );
  }

  /// Estados de UI
  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Inicializando...'),
          ],
        ),
      ),
    );
  }

  Widget _buildRedirectingState() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Redirigiendo al login...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text('Error', style: AppTextStyles.poppinsHeading2),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTextStyles.interBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _redirectToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/driver-login',
        (route) => false,
      );
    });
  }
}
