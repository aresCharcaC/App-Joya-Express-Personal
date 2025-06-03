import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../presentation/modules/pasajero/profile/widgets/app_drawer.dart';
import '../viewmodels/map_viewmodel.dart';
import '../widgets/map_view_widget.dart';
import '../widgets/location_input_panel.dart';
import 'destination_search_screen.dart';

/// Pantalla principal del mapa después del login
class MapMainScreen extends StatefulWidget {
  const MapMainScreen({super.key});

  @override
  State<MapMainScreen> createState() => _MapMainScreenState();
}

class _MapMainScreenState extends State<MapMainScreen> {
  late MapViewModel _mapViewModel;

  @override
  void initState() {
    super.initState();
    _mapViewModel = Provider.of<MapViewModel>(context, listen: false);

    // Inicializar mapa después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapViewModel.initializeMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      // Drawer reutilizado de tu proyecto
      drawer: const AppDrawer(),
      body: Consumer<MapViewModel>(
        builder: (context, mapViewModel, child) {
          return Stack(
            children: [
              // Mapa de fondo (ocupa toda la pantalla)
              const MapViewWidget(),

              // Header transparente con menú
              _buildTransparentHeader(context),

              // Panel inferior con controles
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LocationInputPanel(
                  onDestinationTap: _handleDestinationTap,
                  onTripOfferTap: _handleTripOfferTap,
                  onSearchMototaxiTap: _handleSearchMototaxiTap,
                ),
              ),

              // Indicador de punto de recogida (cuando está seleccionado)
              if (mapViewModel.hasPickupLocation)
                _buildPickupIndicator(mapViewModel),

              // Overlay de error
              if (mapViewModel.hasError) _buildErrorOverlay(mapViewModel),
            ],
          );
        },
      ),
    );
  }

  /// Header transparente con menú hamburguesa
  Widget _buildTransparentHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Botón de menú
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const Spacer(),
              // Aquí podrías agregar más botones si necesitas
            ],
          ),
        ),
      ),
    );
  }

  /// Indicador flotante del punto de recogida (simplificado)
  Widget _buildPickupIndicator(MapViewModel mapViewModel) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.25,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Punto de recogida',
            style: AppTextStyles.interCaption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Overlay de error
  Widget _buildErrorOverlay(MapViewModel mapViewModel) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mapViewModel.errorMessage ?? 'Ha ocurrido un error',
                style: AppTextStyles.interBody.copyWith(color: AppColors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.white),
              onPressed: () {
                // Reintentar inicialización
                _mapViewModel.initializeMap();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Manejar toque en campo destino
  void _handleDestinationTap() {
    // Navegar al modal de búsqueda de destino
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DestinationSearchScreen(),
    );
  }

  /// Manejar toque en botón de tarifa
  void _handleTripOfferTap() {
    // TODO: Implementar pantalla de tarifa
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurar tarifa - Próximamente'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  /// Manejar búsqueda de mototaxi
  void _handleSearchMototaxiTap() {
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);

    if (mapViewModel.canCalculateRoute) {
      // TODO: Implementar búsqueda de mototaxi real
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Buscando mototaxi desde ${mapViewModel.pickupLocation!.address ?? 'punto seleccionado'} hasta ${mapViewModel.destinationLocation!.address ?? 'destino'}',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
