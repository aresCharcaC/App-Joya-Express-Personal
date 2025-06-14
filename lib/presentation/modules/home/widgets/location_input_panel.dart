import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../viewmodels/map_viewmodel.dart';
import 'trip_offer_bottom_sheet.dart';
import '../../../../presentation/providers/ride_provider.dart';
import '../../../../domain/entities/ride_request_entity.dart';

/// Panel inferior con campos de origen y destino
/// Este widget maneja la interfaz para seleccionar ubicaciones y crear solicitudes de viaje
class LocationInputPanel extends StatelessWidget {
  // Callbacks para manejar interacciones del usuario
  final VoidCallback? onDestinationTap;      // Se llama al tocar el campo de destino
  final VoidCallback? onTripOfferTap;        // Se llama al tocar el botón de tarifa
  final VoidCallback? onSearchMototaxiTap;   // Se llama al tocar el botón de búsqueda

  const LocationInputPanel({
    super.key,
    this.onDestinationTap,
    this.onTripOfferTap,
    this.onSearchMototaxiTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer2 para escuchar cambios en MapViewModel y RideProvider
    return Consumer2<MapViewModel, RideProvider>(
      builder: (context, mapViewModel, rideProvider, child) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF2D2D2D), // Fondo oscuro del panel
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
                  // Campo para mostrar/seleccionar punto de recogida
                  _buildPickupField(mapViewModel),

                  const SizedBox(height: 12),

                  // Campo para mostrar/seleccionar destino
                  _buildDestinationField(mapViewModel),

                  const SizedBox(height: 16),

                  // Botón para configurar tarifa del viaje
                  _buildTripOfferButton(context, mapViewModel),

                  const SizedBox(height: 12),

                  // Botón principal para buscar mototaxi
                  _buildSearchButton(context, mapViewModel, rideProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construye el campo de punto de recogida
  /// Muestra un pin blanco y la dirección seleccionada
  Widget _buildPickupField(MapViewModel mapViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Pin blanco indicador de origen
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

  /// Construye el campo de destino
  /// Muestra un icono de lugar y la dirección seleccionada
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
            // Icono que cambia según si hay destino seleccionado
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

  /// Construye el botón de tarifa
  /// Muestra el precio sugerido y permite configurar la tarifa
  Widget _buildTripOfferButton(
    BuildContext context,
    MapViewModel mapViewModel,
  ) {
    final bool hasRoute = mapViewModel.hasRoute;
    final bool hasDestination = mapViewModel.hasDestinationLocation;

    return GestureDetector(
      onTap: () {
        if (!hasDestination) {
          // Mostrar mensaje si no hay destino seleccionado
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
          // Mostrar bottom sheet de tarifa si hay ruta calculada
          _showTripOfferBottomSheet(context);
        } else {
          onTripOfferTap?.call();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF505050),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icono de dinero
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

  /// Construye el botón principal de búsqueda
  /// Integra RideProvider para crear solicitudes de viaje
  Widget _buildSearchButton(
    BuildContext context,
    MapViewModel mapViewModel,
    RideProvider rideProvider,
  ) {
    final bool canSearch = mapViewModel.canCalculateRoute;
    final bool isLoading = rideProvider.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canSearch && !isLoading
            ? () => _handleSearchMototaxi(context, mapViewModel, rideProvider)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSearch ? AppColors.primary : AppColors.buttonDisabled,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Buscar Mototaxi',
                style: AppTextStyles.poppinsButton.copyWith(
                  color: canSearch ? AppColors.white : AppColors.buttonTextDisabled,
                ),
              ),
      ),
    );
  }

  /// Maneja la creación de solicitud de viaje
  /// Valida los datos y crea la solicitud usando RideProvider
  Future<void> _handleSearchMototaxi(
    BuildContext context,
    MapViewModel mapViewModel,
    RideProvider rideProvider,
  ) async {
    // Validar que existan todos los datos necesarios
    if (!mapViewModel.hasRoute || !mapViewModel.hasPickupLocation || !mapViewModel.hasDestinationLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se puede crear la solicitud de viaje'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Crear objeto RideRequest con los datos del mapa
      final request = RideRequest(
        origenLat: mapViewModel.pickupLocation!.coordinates.latitude,
        origenLng: mapViewModel.pickupLocation!.coordinates.longitude,
        destinoLat: mapViewModel.destinationLocation!.coordinates.latitude,
        destinoLng: mapViewModel.destinationLocation!.coordinates.longitude,
        origenDireccion: mapViewModel.pickupLocation!.address,
        destinoDireccion: mapViewModel.destinationLocation!.address,
        precioSugerido: mapViewModel.routeDistance * 1.0 + 3.0, // 3 soles base + 1 sol por km
        metodoPagoPreferido: 'efectivo', // Por defecto efectivo
        estado: 'pendiente',
        fechaCreacion: DateTime.now(),
      );

      // Enviar solicitud usando el provider y esperar la respuesta
      final success = await rideProvider.createRideRequest(request);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Buscando mototaxi...'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          // Si no fue exitoso, mostrar el error del provider
          String errorMessage = 'Error al crear la solicitud';
          
          if (rideProvider.error != null) {
            if (rideProvider.error!.contains('NO hay conductores cercanos disponibles')) {
              errorMessage = 'No hay conductores disponibles en tu zona. Por favor, intenta más tarde.';
            } else if (rideProvider.error!.contains('Error de validación')) {
              errorMessage = 'Error en los datos de la solicitud. Por favor, verifica la información.';
            } else if (rideProvider.error!.contains('Error de autenticación')) {
              errorMessage = 'Error de sesión. Por favor, vuelve a iniciar sesión.';
            } else if (rideProvider.error!.contains('Error de conexión')) {
              errorMessage = 'Error de conexión. Por favor, verifica tu conexión a internet.';
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Entendido',
                textColor: AppColors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Error al crear la solicitud';
        
        if (e.toString().contains('NO hay conductores cercanos disponibles')) {
          errorMessage = 'No hay conductores disponibles en tu zona. Por favor, intenta más tarde.';
        } else if (e.toString().contains('Error de validación')) {
          errorMessage = 'Error en los datos de la solicitud. Por favor, verifica la información.';
        } else if (e.toString().contains('Error de autenticación')) {
          errorMessage = 'Error de sesión. Por favor, vuelve a iniciar sesión.';
        } else if (e.toString().contains('Error de conexión')) {
          errorMessage = 'Error de conexión. Por favor, verifica tu conexión a internet.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Entendido',
              textColor: AppColors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  /// Calcula el precio sugerido basado en la distancia
  /// Fórmula: 3 soles base + 1 sol por kilómetro
  int _calculateSuggestedPrice(double distanceKm) {
    final price = 3.0 + (distanceKm * 1.0);
    return ((price * 2).round() / 2).round(); // Redondear a .5 más cercano
  }

  /// Muestra el bottom sheet para configurar la tarifa
  void _showTripOfferBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TripOfferBottomSheet(),
    );
  }
}
