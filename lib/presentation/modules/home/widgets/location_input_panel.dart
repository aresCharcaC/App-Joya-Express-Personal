import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../viewmodels/map_viewmodel.dart';
import 'trip_offer_bottom_sheet.dart';

/// Panel inferior con campos de origen y destino
class LocationInputPanel extends StatelessWidget {
  final VoidCallback? onDestinationTap;
  final VoidCallback? onTripOfferTap;
  final VoidCallback? onSearchMototaxiTap;

  const LocationInputPanel({
    super.key,
    this.onDestinationTap,
    this.onTripOfferTap,
    this.onSearchMototaxiTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, child) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF2D2D2D), // Gris oscuro como en la foto
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo de origen (punto de recogida)
                  _buildPickupField(mapViewModel),

                  const SizedBox(height: 12),

                  // Campo de destino
                  _buildDestinationField(mapViewModel),

                  const SizedBox(height: 16),

                  // Botón de tarifa (ACTUALIZADO con validación)
                  _buildTripOfferButton(context, mapViewModel),

                  const SizedBox(height: 12),

                  // Botón principal (ACTUALIZADO con mensaje de desarrollo)
                  _buildSearchButton(context, mapViewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Campo de punto de recogida
  Widget _buildPickupField(MapViewModel mapViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D), // Mismo color del panel
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Pin blanco
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mapViewModel.hasPickupLocation
                  ? (mapViewModel.pickupLocation!.address ??
                      'Ubicación seleccionada')
                  : 'Seleccionar punto de recogida',
              style: AppTextStyles.interBody.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Campo de destino (CON X para borrar cuando hay destino)
  Widget _buildDestinationField(MapViewModel mapViewModel) {
    final bool hasDestination = mapViewModel.hasDestinationLocation;

    return GestureDetector(
      onTap: onDestinationTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF505050), // Gris más claro que el panel
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icono - cambia según si hay destino
            Icon(
              hasDestination ? Icons.place : Icons.search,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasDestination
                    ? (mapViewModel.destinationLocation!.address ??
                        'Destino seleccionado')
                    : 'Destino',
                style: AppTextStyles.interBody.copyWith(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight:
                      hasDestination ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón de tarifa (ACTUALIZADO - Con validación de destino)
  Widget _buildTripOfferButton(
    BuildContext context,
    MapViewModel mapViewModel,
  ) {
    final bool hasRoute = mapViewModel.hasRoute;
    final bool hasDestination = mapViewModel.hasDestinationLocation;

    return GestureDetector(
      onTap: () {
        if (!hasDestination) {
          // Mostrar mensaje si no hay destino
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Establece un destino primero'),
              backgroundColor: AppColors.info,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        if (hasRoute) {
          _showTripOfferBottomSheet(context);
        } else {
          onTripOfferTap?.call();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF505050), // Gris más claro que el panel
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icono de dinero rojo
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.monetization_on_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasRoute ? 'Configurar Tarifa' : 'Brinda una oferta',
                    style: AppTextStyles.interBody.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight:
                          hasRoute ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  if (hasRoute) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Precio sugerido: S/${_calculateSuggestedPrice(mapViewModel.routeDistance)}',
                      style: AppTextStyles.interCaption.copyWith(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasRoute)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.white.withOpacity(0.5),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  /// Botón principal de búsqueda (ACTUALIZADO - Mensaje de desarrollo)
  Widget _buildSearchButton(BuildContext context, MapViewModel mapViewModel) {
    final bool canSearch = mapViewModel.canCalculateRoute;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
            canSearch
                ? () {
                  // Mostrar mensaje de desarrollo en lugar de funcionalidad
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función en desarrollo - Próximamente'),
                      backgroundColor: AppColors.info,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canSearch ? AppColors.primary : AppColors.buttonDisabled,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Buscar Mototaxi',
          style: AppTextStyles.poppinsButton.copyWith(
            color: canSearch ? AppColors.white : AppColors.buttonTextDisabled,
          ),
        ),
      ),
    );
  }

  /// Calcula el precio sugerido (3 soles base + 1 sol por km)
  int _calculateSuggestedPrice(double distanceKm) {
    final price = 3.0 + (distanceKm * 1.0);
    return ((price * 2).round() / 2).round(); // Redondear a .5 más cercano
  }

  /// Muestra el bottom sheet de tarifa
  void _showTripOfferBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TripOfferBottomSheet(),
    );
  }
}
